# IAM Module - main.tf

variable "environment" {
  description = "The environment (dev, staging, prod)"
  type        = string
}

variable "db_instance_arn" {
  description = "The ARN of the RDS instance"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "my-project"
}

# Create IAM role for DB administrators
resource "aws_iam_role" "db_admin_role" {
  name = "${var.environment}-${var.project_name}-db-admin-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ]
  })

  # We also want to allow developers to assume this role
  inline_policy {
    name = "allow-human-assume-role"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = "sts:AssumeRole",
          Effect = "Allow",
          Principal = {
            AWS = "arn:aws:iam::*:user/admin-*"
          },
          Condition = {
            StringEquals = {
              "aws:PrincipalTag/Environment": var.environment
            }
          }
        }
      ]
    })
  }

  tags = {
    Name        = "${var.environment}-db-admin-role"
    Environment = var.environment
  }
}

# Create policy for DB administrators with full access to the RDS instance
resource "aws_iam_policy" "db_admin_policy" {
  name        = "${var.environment}-${var.project_name}-db-admin-policy"
  description = "Policy for database administrators"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "rds:*"
        ],
        Effect = "Allow",
        Resource = var.db_instance_arn
      },
      {
        Action = [
          "rds:Describe*",
          "rds:List*"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Attach DB admin policy to DB admin role
resource "aws_iam_role_policy_attachment" "db_admin_policy_attachment" {
  role       = aws_iam_role.db_admin_role.name
  policy_arn = aws_iam_policy.db_admin_policy.arn
}

# Create IAM role for DB migrations
resource "aws_iam_role" "db_migration_role" {
  name = "${var.environment}-${var.project_name}-db-migration-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "codebuild.amazonaws.com",
            "codepipeline.amazonaws.com"
          ]
        },
      },
    ]
  })

  tags = {
    Name        = "${var.environment}-db-migration-role"
    Environment = var.environment
  }
}

# Create policy for DB migrations with limited access to the RDS instance
resource "aws_iam_policy" "db_migration_policy" {
  name        = "${var.environment}-${var.project_name}-db-migration-policy"
  description = "Policy for database migrations"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:DescribeDBClusterParameters",
          "rds:DescribeDBParameters"
        ],
        Effect = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "rds:ModifyDBInstance",
          "rds:ModifyDBCluster"
        ],
        Effect = "Allow",
        Resource = var.db_instance_arn,
        Condition = {
          StringEquals = {
            "rds:DatabaseClass": [
              "db.t3.*",
              "db.m5.*"
            ]
          }
        }
      }
    ]
  })
}

# Attach DB migration policy to DB migration role
resource "aws_iam_role_policy_attachment" "db_migration_policy_attachment" {
  role       = aws_iam_role.db_migration_role.name
  policy_arn = aws_iam_policy.db_migration_policy.arn
}

# Create IAM group for database administrators
resource "aws_iam_group" "db_admins" {
  name = "${var.environment}-${var.project_name}-db-admins"
}

# Create policy to allow DB admins group to assume DB admin role
resource "aws_iam_policy" "assume_db_admin_role" {
  name        = "${var.environment}-${var.project_name}-assume-db-admin-role"
  description = "Policy to allow assuming DB admin role"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Resource = aws_iam_role.db_admin_role.arn
      }
    ]
  })
}

# Attach assume DB admin role policy to DB admins group
resource "aws_iam_group_policy_attachment" "db_admins_assume_role" {
  group      = aws_iam_group.db_admins.name
  policy_arn = aws_iam_policy.assume_db_admin_role.arn
}

# Outputs
output "db_admin_role_arn" {
  description = "ARN of the DB administrator role"
  value       = aws_iam_role.db_admin_role.arn
}

output "db_migration_role_arn" {
  description = "ARN of the DB migration role"
  value       = aws_iam_role.db_migration_role.arn
}

output "db_admins_group_name" {
  description = "Name of the DB administrators group"
  value       = aws_iam_group.db_admins.name
}