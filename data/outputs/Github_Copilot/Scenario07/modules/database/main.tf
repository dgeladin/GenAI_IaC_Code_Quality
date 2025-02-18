
variable "environment" {
  description = "The environment to deploy into"
  type        = string
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_username" {
  description = "The database username"
  type        = string
}

variable "db_password" {
  description = "The database password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "The RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "The allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_port" {
  description = "The database port"
  type        = number
  default     = 5432
}

variable "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  type        = string
}

variable "db_security_group_id" {
  description = "The ID of the database security group"
  type        = string
}

resource "aws_db_instance" "example" {
  allocated_storage    = var.db_allocated_storage
  engine               = "postgres"
  engine_version       = "12.5"
  instance_class       = var.db_instance_class
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  port                 = var.db_port
  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_security_group_id]
  skip_final_snapshot  = true

  tags = {
    Name        = "${var.environment}-db-instance"
    Environment = var.environment
  }
}

output "db_endpoint" {
  value = aws_db_instance.example.endpoint
}
