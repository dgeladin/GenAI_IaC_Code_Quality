variable "environment" {
  description = "The environment name (e.g., development, staging, production)"
  type        = string
}

# IAM Role for DB Administrators
resource "aws_iam_role" "db_admin_role" {
  name = "${var.environment}_db_admin_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "*"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "db_admin_policy" {
  name        = "${var.environment}_db_admin_policy"
  description = "Full access to RDS instance for database administrators"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "rds:*",
        "rds-db:connect"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "db_admin_attachment" {
  role       = aws_iam_role.db_admin_role.name
  policy_arn = aws_iam_policy.db_admin_policy.arn
}

# IAM Role for DB Migrations
resource "aws_iam_role" "db_migration_role" {
  name = "${var.environment}_db_migration_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "*"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "db_migration_policy" {
  name        = "${var.environment}_db_migration_policy"
  description = "Limited access to RDS for database migrations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "rds:DescribeDBInstances",
        "rds:DescribeDBClusters",
        "rds-db:connect"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "db_migration_attachment" {
  role       = aws_iam_role.db_migration_role.name
  policy_arn = aws_iam_policy.db_migration_policy.arn
}

# IAM Users and Group for access management
resource "aws_iam_group" "db_admins" {
  name = "${var.environment}_db_admins"
}

resource "aws_iam_group_policy_attachment" "db_admins_attachment" {
  group      = aws_iam_group.db_admins.name
  policy_arn = aws_iam_policy.db_admin_policy.arn
}

resource "aws_iam_user" "db_admin_user" {
  name = "${var.environment}_db_admin"
}

resource "aws_iam_user_group_membership" "db_admin_user_membership" {
  user  = aws_iam_user.db_admin_user.name
  groups = [aws_iam_group.db_admins.name]
}


