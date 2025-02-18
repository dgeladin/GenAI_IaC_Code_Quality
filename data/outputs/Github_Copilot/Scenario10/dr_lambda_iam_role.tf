terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  alias   = "primary"
  region  = "us-west-2"
}

provider "aws" {
  alias   = "dr"
  region  = "us-east-1"
}

resource "aws_iam_role" "dr_lambda_role" {
  name = "dr_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "dr_lambda_role"
    Environment = "DR"
  }
}

resource "aws_iam_policy" "dr_lambda_policy" {
  name        = "dr_lambda_policy"
  description = "Policy for DR Lambda function execution"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "drs:StartFailbackLaunch",
          "drs:DescribeRecoveryInstances",
          "drs:ListRecoveryInstances"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = "sns:Publish",
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dr_lambda_policy_attachment" {
  role       = aws_iam_role.dr_lambda_role.name
  policy_arn = aws_iam_policy.dr_lambda_policy.arn
}

output "iam_role_arn" {
  value = aws_iam_role.dr_lambda_role.arn
}