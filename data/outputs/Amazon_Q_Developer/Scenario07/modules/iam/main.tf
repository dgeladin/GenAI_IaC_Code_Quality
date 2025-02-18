locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# Database Administrator Role
resource "aws_iam_role" "db_admin" {
  name = "${var.project}-${var.environment}-db-admin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
          AWS     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-db-admin-role"
  })
}

# Database Administrator Policy
resource "aws_iam_role_policy" "db_admin" {
  name = "${var.project}-${var.environment}-db-admin-policy"
  role = aws_iam_role.db_admin.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:*"
        ]
        Resource = [
          var.db_instance_arn,
          "${var.db_instance_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "rds:Describe*",
          "rds:List*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Database Migration Role
resource "aws_iam_role" "db_migration" {
  name = "${var.project}-${var.environment}-db-migration"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
          AWS     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-db-migration-role"
  })
}

# Database Migration Policy
resource "aws_iam_role_policy" "db_migration" {
  name = "${var.project}-${var.environment}-db-migration-policy"
  role = aws_iam_role.db_migration.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect",
          "rds:DescribeDBInstances"
        ]
        Resource = [
          var.db_instance_arn,
          "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${var.db_resource_id}/*"
        ]
      }
    ]
  })
}

# Get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create an IAM group for database administrators
resource "aws_iam_group" "db_admins" {
  name = "${var.project}-${var.environment}-db-admins"
}

# Attach policy allowing assumption of the db_admin role to the group
resource "aws_iam_group_policy" "db_admins" {
  name  = "${var.project}-${var.environment}-assume-db-admin"
  group = aws_iam_group.db_admins.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = [
          aws_iam_role.db_admin.arn
        ]
      }
    ]
  })
}
