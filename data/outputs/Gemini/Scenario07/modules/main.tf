# main.tf (in the root directory)

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Or your preferred version
    }
  }
}

provider "aws" {
  region = "us-east-1" # Your preferred region
}

locals {
  environment = terraform.workspace
}

# Network Module
module "network" {
  source = "./modules/network"
  environment = local.environment
}

# Database Module
module "database" {
  source = "./modules/database"
  environment = local.environment
  db_name = "mydb"
  db_username = "admin"
  db_password = random_password.db_admin_password.result # From random_password resource
  db_allocated_storage = 20
  db_subnet_group_name = module.network.db_subnet_group_name # Created below
  db_security_group_id = module.network.database_sg_id # Created below
}

# Compute Module
module "compute" {
  source = "./modules/compute"
  environment = local.environment
  public_subnet_ids = module.network.public_subnet_ids
  web_server_sg_id = module.network.web_server_sg_id
}


# IAM Roles and Policies

resource "aws_iam_role" "db_admin_role" {
  name = "${local.environment}-db-admin-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" # Example, could be your GitHub Actions role or user
        }
      },
    ]
  })
}

resource "aws_iam_policy" "db_admin_policy" {
  name = "${local.environment}-db-admin-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "rds:*" # Full RDS access - restrict in production!
        Effect = "Allow"
        Resource = "*" # Restrict to your RDS instance ARN in production!
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "db_admin_attachment" {
  role       = aws_iam_role.db_admin_role.name
  policy_arn = aws_iam_policy.db_admin_policy.arn
}


resource "aws_iam_role" "db_migration_role" {
  name = "${local.environment}-db-migration-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" # Example, could be your GitHub Actions role or user
        }
      },
    ]
  })
}

resource "aws_iam_policy" "db_migration_policy" {
  name = "${local.environment}-db-migration-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds-db:connect", # Allows connection
          "rds:*" # Allows all RDS actions. Restrict to your RDS instance ARN in production!
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "db_migration_attachment" {
  role       = aws_iam_role.db_migration_role.name
  policy_arn = aws_iam_policy.db_migration_policy.arn
}


# DB Subnet Group (moved here from network module)
resource "aws_db_subnet_group" "main" {
  name        = "${local.environment}-db-subnet-group"
  subnet_ids = module.network.private_subnet_ids

  tags = {
    Name        = local.environment
    Environment = local.environment
  }
}

# Add database_sg to network module.
# The network module will now output the security group id.

# Random password generation for database admin (for demonstration ONLY - use Secrets Manager in production)
resource "random_password" "db_admin_password" {
  length  = 16
  special = true
}

output "db_endpoint" {
  value = module.database.db_endpoint
}

output "alb_dns_name" {
    value = module.compute.alb_dns_name
}