terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "template_file" "migration_script" {
  template = file("${path.module}/migrations/V1__initial_schema.sql")
}

resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Security group for RDS MySQL instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "MySQL from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db_sg"
  }
}

resource "aws_db_subnet_group" "example" {
  name       = "example-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "example-db-subnet-group"
  }
}

resource "aws_db_instance" "example" {
  identifier           = "example-db"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  db_name             = "myapp"
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.example.name
}

resource "null_resource" "db_migration" {
  triggers = {
    migration_hash = sha256(data.template_file.migration_script.rendered)
  }

  depends_on = [aws_db_instance.example]

  provisioner "local-exec" {
    command = <<EOF
      mysql -h ${aws_db_instance.example.endpoint} \
            -u ${var.db_username} \
            -p${var.db_password} \
            ${aws_db_instance.example.db_name} \
            < ${path.module}/migrations/V1__initial_schema.sql
    EOF
  }
}