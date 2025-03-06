resource "aws_iam_role" "db_admin_role" {
  name = "${var.environment}-db-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "db_admin_policy" {
  name = "${var.environment}-db-admin-policy"
  role = aws_iam_role.db_admin_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "rds:*"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "db_migration_role" {
  name = "${var.environment}-db-migration-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "db_migration_policy" {
  name = "${var.environment}-db-migration-policy"
  role = aws_iam_role.db_migration_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "rds:Connect",
          "rds:DescribeDBInstances",
          "rds:DescribeDBSnapshots",
          "rds:ListTagsForResource"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user" "db_admin_user" {
  name = "${var.environment}-db-admin-user"
}

resource "aws_iam_user" "db_migration_user" {
  name = "${var.environment}-db-migration-user"
}

resource "aws_iam_user_policy_attachment" "db_admin_attachment" {
  user       = aws_iam_user.db_admin_user.name
  policy_arn = aws_iam_role_policy.db_admin_policy.arn
}

resource "aws_iam_user_policy_attachment" "db_migration_attachment" {
  user       = aws_iam_user.db_migration_user.name
  policy_arn = aws_iam_role_policy.db_migration_policy.arn
}
