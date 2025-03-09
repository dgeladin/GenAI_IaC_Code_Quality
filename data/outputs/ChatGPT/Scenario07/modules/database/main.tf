terraform {
  required_version = ">= 1.8"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "db_subnet_group_name" {
  description = "DB subnet group name"
  type        = string
}

variable "db_security_group_id" {
  description = "Database security group ID"
  type        = string
}

resource "aws_db_instance" "database" {
  identifier              = "${var.environment}-db"
  engine                  = "postgres"
  engine_version          = "14"
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  vpc_security_group_ids = [var.db_security_group_id]
  db_subnet_group_name   = var.db_subnet_group_name
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name = "${var.environment}-database"
  }
}

output "db_endpoint" {
  value = aws_db_instance.database.endpoint
}

