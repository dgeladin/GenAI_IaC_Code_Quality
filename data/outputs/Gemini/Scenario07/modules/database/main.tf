# ../modules/database/main.tf

variable "environment" {
  type = string
  description = "Deployment environment (development, staging, production)"
}

variable "db_name" {
  type = string
  description = "Name of the database"
}

variable "db_username" {
  type = string
  description = "Database username"
}

variable "db_password" {
  type = string
  description = "Database password (STORE SECURELY - use a secrets manager in production)"
  sensitive = true  # Mark as sensitive
}

variable "db_instance_class" {
  type = map(string)
  description = "RDS instance class per environment"
  default = {
    development = "db.t3.micro"
    staging     = "db.t3.medium"
    production  = "db.m5.large"
  }
}

variable "db_allocated_storage" {
  type = number
  description = "Allocated storage for the database (GB)"
  default = 20 # Example
}

variable "db_port" {
  type = number
  description = "Database port"
  default = 5432 # PostgreSQL
}

variable "db_subnet_group_name" {
  type = string
  description = "Name of the DB subnet group"
}

variable "db_security_group_id" {
  type = string
  description = "ID of the database security group"
}


resource "aws_db_instance" "main" {
  identifier           = "${var.environment}-${var.db_name}"
  allocated_storage    = var.db_allocated_storage
  db_name              = var.db_name
  engine             = "postgres"
  engine_version     = "15" # Specify your desired version
  instance_class       = var.db_instance_class[var.environment]
  username             = var.db_username
  password             = var.db_password # In production, use a secrets manager!
  port                = var.db_port
  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible = false # For security, usually keep this false
  skip_final_snapshot = true # For development/testing. Set to false for production!

  tags = {
    Name        = "${var.environment}-${var.db_name}"
    Environment = var.environment
  }
}


output "db_endpoint" {
  value = aws_db_instance.main.endpoint
  sensitive = false # Endpoint is not sensitive
}