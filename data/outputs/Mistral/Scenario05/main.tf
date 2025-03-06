terraform {
  required_version = ">= 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# RDS Instance
resource "aws_db_instance" "example_db" {
  identifier             = "example-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "myapp"
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.example_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
}

# DB Subnet Group
resource "aws_db_subnet_group" "example_db_subnet_group" {
  name       = "example-db-subnet-group"
  subnet_ids = var.private_subnet_ids
}

# Security Group
resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Security group for the RDS instance"
  vpc_id      = "vpc-xxxxxx" # Replace with your actual VPC ID

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # VPC CIDR block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Template file for SQL script
data "template_file" "migration_script" {
  template = file("${path.module}/migrations/V1__initial_schema.sql")
}

# Null resource for database migration
resource "null_resource" "db_migration" {
  triggers = {
    script_hash = sha256(data.template_file.migration_script.rendered)
  }

  provisioner "local-exec" {
    command = <<EOT
      mysql --host=${aws_db_instance.example_db.endpoint} \
             --user=${var.db_username} \
             --password=${var.db_password} \
             --database=myapp < ${path.module}/migrations/V1__initial_schema.sql
    EOT
  }

  depends_on = [aws_db_instance.example_db]
}
