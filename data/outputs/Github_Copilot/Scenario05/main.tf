provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "example_db" {
  identifier            = "example-db"
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  db_name               = var.db_name
  username              = var.db_username
  password              = var.db_password
  db_subnet_group_name  = aws_db_subnet_group.example_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  # Enable storage encryption
  storage_encrypted = true

  # Apply a final snapshot before deletion
  final_snapshot_identifier = "example-db-final-snapshot"
}

resource "aws_db_subnet_group" "example_db_subnet_group" {
  name       = "example-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "example-db-subnet-group"
  }
}

resource "aws_security_group" "db_sg" {
  name_prefix = "example-db-sg-"
  description = "Allow inbound traffic to RDS example-db"

  vpc_id = var.vpc_id

  ingress {
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
    Name = "example-db-sg"
  }
}

data "template_file" "migration_script" {
  template = file("${path.module}/migrations/V1__initial_schema.sql")
}

resource "null_resource" "db_migration" {
  triggers = {
    migration_sha = sha256(data.template_file.migration_script.rendered)
  }

  provisioner "local-exec" {
    command = <<EOT
      mysql -h ${aws_db_instance.example_db.endpoint} -u${var.db_username} -p${var.db_password} ${var.db_name} < ${path.module}/migrations/V1__initial_schema.sql
    EOT
  }

  depends_on = [aws_db_instance.example_db]
}