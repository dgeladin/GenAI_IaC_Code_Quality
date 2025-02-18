# Template file for the migration script
data "template_file" "initial_schema" {
  template = file("${path.module}/migrations/V1__initial_schema.sql")
}

# Random string for migration tracking
resource "random_string" "migration_id" {
  length  = 8
  special = false
}

# SSM Parameter for migration state tracking
resource "aws_ssm_parameter" "migration_state" {
  name        = "${local.ssm_path_prefix}/migration-state"
  description = "Database migration state tracking"
  type        = "String"
  value       = jsonencode({
    id            = random_string.migration_id.result
    last_applied  = data.time_static.current.rfc3339
    version       = local.migration_version
    script_hash   = sha256(data.template_file.initial_schema.rendered)
  })
  overwrite   = true

  tags = local.common_tags
}

# Null resource for database migration
resource "null_resource" "database_migration" {
  count = var.enable_migrations ? 1 : 0

  triggers = {
    instance_id    = aws_db_instance.example.id
    migration_hash = sha256(data.template_file.initial_schema.rendered)
    migration_id   = random_string.migration_id.result
  }

  provisioner "local-exec" {
    working_dir = path.module
    
    command = <<-EOF
      # Wait for database to be available
      echo "Waiting for database to be available..."
      timeout=${var.migration_timeout}
      counter=0
      until mysql \
        -h ${aws_db_instance.example.endpoint} \
        -u ${var.db_username} \
        -P ${local.db_port} \
        -e "SELECT 1" > /dev/null 2>&1; do
        if [ $counter -gt $timeout ]; then
          echo "Timeout waiting for database"
          exit 1
        fi
        echo "Waiting for database connection..."
        sleep 5
        counter=$((counter+5))
      done

      # Create migrations table if it doesn't exist
      mysql \
        -h ${aws_db_instance.example.endpoint} \
        -u ${var.db_username} \
        -P ${local.db_port} \
        ${aws_db_instance.example.db_name} \
        -e "CREATE TABLE IF NOT EXISTS schema_migrations (
          version varchar(255) NOT NULL,
          applied_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
          script_hash varchar(64) NOT NULL,
          PRIMARY KEY (version)
        );"

      # Execute migration
      echo "Executing database migration..."
      mysql \
        -h ${aws_db_instance.example.endpoint} \
        -u ${var.db_username} \
        -P ${local.db_port} \
        ${aws_db_instance.example.db_name} << EOSQL
      ${data.template_file.initial_schema.rendered}

      INSERT INTO schema_migrations (version, script_hash)
      VALUES ('${local.migration_version}', '${sha256(data.template_file.initial_schema.rendered)}')
      ON DUPLICATE KEY UPDATE
        script_hash = VALUES(script_hash),
        applied_at = CURRENT_TIMESTAMP;
EOSQL

      # Update migration status
      echo "Migration completed successfully"
    EOF

    environment = {
      MYSQL_PWD = var.db_password
    }
  }

  depends_on = [
    aws_db_instance.example,
    aws_security_group.db_sg,
    aws_db_subnet_group.example
  ]
}

# CloudWatch Log Group for migration logs
resource "aws_cloudwatch_log_group" "migration_logs" {
  name              = "/aws/rds/migration/${local.name_prefix}"
  retention_in_days = 30

  tags = local.common_tags
}
