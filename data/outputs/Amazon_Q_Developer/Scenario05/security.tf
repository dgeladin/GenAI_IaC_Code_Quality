# Security Group for RDS
resource "aws_security_group" "db_sg" {
  name_prefix = local.sg_name
  description = "Security group for RDS MySQL instance"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = local.sg_name
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group Rules
resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = local.db_port
  to_port           = local.db_port
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  security_group_id = aws_security_group.db_sg.id
  description       = "Allow MySQL inbound traffic from VPC"
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db_sg.id
  description       = "Allow all outbound traffic"
}

# IAM Role for Enhanced Monitoring
resource "aws_iam_role" "rds_monitoring_role" {
  name_prefix = local.monitoring_role_name
  description = "IAM role for RDS enhanced monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Attach Enhanced Monitoring Policy
resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# KMS Key for RDS Encryption (if custom key is required)
resource "aws_kms_key" "rds" {
  count = var.use_custom_kms_key ? 0 : 1

  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.common_tags
}

resource "aws_kms_alias" "rds" {
  count = var.use_custom_kms_key ? 0 : 1

  name          = "alias/${local.name_prefix}-rds"
  target_key_id = aws_kms_key.rds[0].key_id
}

# Parameter Group
resource "aws_db_parameter_group" "example" {
  name_prefix = local.parameter_group_name
  family      = "mysql8.0"
  description = "Custom parameter group for MySQL 8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  parameter {
    name  = "max_connections"
    value = local.is_production ? "1000" : "100"
  }

  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

# Option Group
resource "aws_db_option_group" "example" {
  name_prefix = local.option_group_name
  engine_name = "mysql"
  major_engine_version = "8.0"

  option {
    option_name = "MARIADB_AUDIT_PLUGIN"

    option_settings {
      name  = "SERVER_AUDIT_EVENTS"
      value = "CONNECT,QUERY,TABLE"
    }
  }

  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

# SSM Parameters for Secrets
resource "aws_ssm_parameter" "db_endpoint" {
  name        = local.ssm_parameters.endpoint
  description = "RDS instance endpoint"
  type        = "String"
  value       = aws_db_instance.example.endpoint
  overwrite   = true

  tags = local.common_tags
}

resource "aws_ssm_parameter" "db_port" {
  name        = local.ssm_parameters.port
  description = "RDS instance port"
  type        = "String"
  value       = tostring(aws_db_instance.example.port)
  overwrite   = true

  tags = local.common_tags
}
