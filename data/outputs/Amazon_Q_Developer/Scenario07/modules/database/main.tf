locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }

  backup_retention_period = {
    development = 1
    staging     = 7
    production  = 30
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name        = "${var.project}-${var.environment}-db-subnet-group"
  description = "Database subnet group for ${var.project} ${var.environment}"
  subnet_ids  = var.private_subnet_ids

  tags = local.common_tags
}

# Security Group for Database
resource "aws_security_group" "database" {
  name_prefix = "${var.project}-${var.environment}-db-"
  description = "Security group for ${var.project} ${var.environment} database"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [var.web_server_sg_id]
    description     = "Allow PostgreSQL access from web servers"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-db-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# KMS Key for database encryption
resource "aws_kms_key" "database" {
  description             = "KMS key for database encryption"
  deletion_window_in_days = 7
  enable_key_rotation    = true

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-db-key"
  })
}

resource "aws_kms_alias" "database" {
  name          = "alias/${var.project}-${var.environment}-db-key"
  target_key_id = aws_kms_key.database.key_id
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.project}-${var.environment}-db"

  # Engine configuration
  engine               = "postgres"
  engine_version       = "14"
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  storage_type         = "gp3"
  storage_encrypted    = true
  kms_key_id          = aws_kms_key.database.arn

  # Database configuration
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible    = false

  # Backup configuration
  backup_retention_period = lookup(local.backup_retention_period, var.environment)
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  # Enhanced monitoring
  monitoring_interval = var.environment == "production" ? 60 : 0
  monitoring_role_arn = var.environment == "production" ? aws_iam_role.rds_monitoring[0].arn : null

  # Performance Insights
  performance_insights_enabled = var.environment == "production"
  performance_insights_retention_period = var.environment == "production" ? 7 : 0

  # Other configurations
  auto_minor_version_upgrade = true
  deletion_protection       = var.environment == "production"
  skip_final_snapshot      = var.environment != "production"
  final_snapshot_identifier = var.environment == "production" ? "${var.project}-${var.environment}-final-snapshot" : null

  tags = local.common_tags
}

# IAM role for enhanced monitoring (only created for production)
resource "aws_iam_role" "rds_monitoring" {
  count = var.environment == "production" ? 1 : 0
  name  = "${var.project}-${var.environment}-rds-monitoring-role"

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

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count      = var.environment == "production" ? 1 : 0
  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
