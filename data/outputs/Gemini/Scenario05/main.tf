# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Or specify your preferred version
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Data source to fetch the default VPC (alternative to hardcoding or variable)
data "aws_vpc" "default" {
  default = true
}

# Create DB Subnet Group
resource "aws_db_subnet_group" "example_db_subnet_group" {
  name        = "example-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "example-db-subnet-group"
  }
}

# Create Security Group
resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Security group for RDS instance"
  vpc_id = data.aws_vpc.default.id # Assuming default VPC or provide vpc_id variable

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic (adjust as needed)
  }

  tags = {
    Name = "db_sg"
  }
}


# Create RDS Instance
resource "aws_db_instance" "example_db" {
  identifier           = "example-db"
  allocated_storage    = 20
  db_name              = "myapp"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.example_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible = false # Good security practice. Access via bastion or other secure means.

  tags = {
    Name = "example-db"
  }
}


# Data source to read the initial schema creation script
data "template_file" "migration_script" {
  template = file("${path.module}/migrations/V1__initial_schema.sql")
}

# Null resource for database migration
resource "null_resource" "db_migration" {
  triggers = {
    migration_hash = sha256(data.template_file.migration_script.rendered)
  }

  depends_on = [aws_db_instance.example_db]

  provisioner "local-exec" {
    command = <<EOT
      mysql -h ${aws_db_instance.example_db.endpoint} -u ${var.db_username} -p${var.db_password} ${aws_db_instance.example_db.db_name} < ${path.module}/migrations/V1__initial_schema.sql
    EOT
  }
}