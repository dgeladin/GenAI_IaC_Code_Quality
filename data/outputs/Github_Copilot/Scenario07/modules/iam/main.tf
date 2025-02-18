
variable "environment" {
  description = "The environment to deploy into"
  type        = string
}

resource "aws_iam_role" "db_admin_role" {
  name = "${var.environment}-db-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "${var.environment}-db-admin-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "db_admin_policy" {
  name   = "${var.environment}-db-admin-policy"
  role   = aws_iam_role.db_admin_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "rds:*",
        "ec2:Describe*"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

resource "aws_iam_role" "db_migration_role" {
  name = "${var.environment}-db-migration-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "${var.environment}-db-migration-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "db_migration_policy" {
  name   = "${var.environment}-db-migration-policy"
  role   = aws_iam_role.db_migration_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "rds-db:connect",
        "rds:DescribeDBInstances",
        "rds:DescribeDBClusters"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

output "db_admin_role_arn" {
  value = aws_iam_role.db_admin_role.arn
}

output "db_migration_role_arn" {
  value = aws_iam_role.db_migration_role.arn
}
