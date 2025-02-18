# Database Module

# Input variables
variable "environment" {
  description = "The name of the environment (e.g., 'development', 'staging', 'production')"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "The database username"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "The database password"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "The database port"
  type        = number
  default     = 5432
}

variable "db_subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "db_security_group_id" {
  description = "The ID of the database security group"
  type        = string
}

# Local variables for environment-specific configurations
locals {
  db_config = {
    development = {
      instance_class    = "db.t3.micro"
      allocated_storage = 20
      multi_az          = false
    },
    staging = {
      instance_class    = "db.t3.medium"
      allocated_storage = 50
      multi_az          = false
    },
    production = {
      instance_class    = "db.m5.large"
      allocated_storage = 100
      multi_az          = true
    }
  }

  # Get configuration based on environment or use default
  config = lookup(local.db_config, var.environment, local.db_config.development)
}

# Create DB subnet group
resource "aws_db_subnet_group" "this" {
  name        = "${var.environment}-db-subnet-group"
  description = "DB subnet group for ${var.environment}"
  subnet_ids  = var.db_subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

# Random string for DB identifier suffix
resource "random_string" "db_identifier_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create PostgreSQL RDS instance
resource "aws_db_instance" "this" {
  identifier = "${var.environment}-db-${random_string.db_identifier_suffix.result}"

  engine            = "postgres"
  engine_version    = "13.7"
  instance_class    = local.config.instance_class
  allocated_storage = local.config.allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  vpc_security_group_ids = [var.db_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.this.name
  
  multi_az               = local.config.multi_az
  publicly_accessible    = false
  
  backup_retention_period = var.environment == "production" ? 7 : 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  # Enable deletion protection in production
  deletion_protection = var.environment == "production" ? true : false
  
  # Skip final snapshot in non-production environments
  skip_final_snapshot = var.environment != "production"
  
  # If final snapshot is needed, provide a name
  final_snapshot_identifier = var.environment == "production" ? "${var.environment}-db-final-snapshot-${random_string.db_identifier_suffix.result}" : null

  # Enhanced monitoring
  monitoring_interval = var.environment == "production" ? 60 : 0
  monitoring_role_arn = var.environment == "production" ? aws_iam_role.rds_monitoring[0].arn : null

  # Parameter group
  parameter_group_name = "default.postgres13"

  # Performance insights
  performance_insights_enabled = var.environment == "production" ? true : false
  performance_insights_retention_period = var.environment == "production" ? 7 : 0

  # Automated backups
  copy_tags_to_snapshot = true
  
  # Auto minor version upgrade
  auto_minor_version_upgrade = true

  # Apply immediately only in non-production environments
  apply_immediately = var.environment != "production"

  tags = {
    Name        = "${var.environment}-postgresql"
    Environment = var.environment
  }

  lifecycle {
    prevent_destroy = var.environment == "production" ? true : false
  }
}

# Create IAM role for RDS enhanced monitoring in production environment
resource "aws_iam_role" "rds_monitoring" {
  count = var.environment == "production" ? 1 : 0
  
  name = "${var.environment}-rds-monitoring-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-rds-monitoring-role"
    Environment = var.environment
  }
}

# Attach the AWS managed policy for RDS enhanced monitoring
resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count = var.environment == "production" ? 1 : 0
  
  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Outputs
output "db_endpoint" {
  description = "The connection endpoint for the database"
  value       = aws_db_instance.this.endpoint
}

output "db_port" {
  description = "The port the database is listening on"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "The name of the database"
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "The master username for the database"
  value       = aws_db_instance.this.username
  sensitive   = true
}