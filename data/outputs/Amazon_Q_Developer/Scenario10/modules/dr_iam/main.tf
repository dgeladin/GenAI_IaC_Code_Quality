# IAM role for DR Lambda function
resource "aws_iam_role" "dr_lambda_role" {
  name = "${var.environment}-${var.function_name}-role"
  path = "/service-roles/dr/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount": data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })

  # Prevent accidental deletion of critical roles
  lifecycle {
    prevent_destroy = var.environment == "prod" ? true : false
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.function_name}-role"
      Purpose     = "lambda-execution"
      Service     = "disaster-recovery"
    }
  )
}

# DRS permissions policy
resource "aws_iam_role_policy" "drs_permissions" {
  name = "${var.environment}-${var.function_name}-drs-policy"
  role = aws_iam_role.dr_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "drs:StartRecovery",
          "drs:StopRecovery",
          "drs:DescribeRecoveryInstances",
          "drs:GetReplicationConfiguration",
          "drs:UpdateReplicationConfiguration",
          "drs:TagResource",
          "drs:DescribeSourceServers",
          "drs:ListTagsForResource"
        ]
        Resource = [
          "arn:aws:drs:*:${data.aws_caller_identity.current.account_id}:recovery-instance/*",
          "arn:aws:drs:*:${data.aws_caller_identity.current.account_id}:source-server/*"
        ]
      }
    ]
  })
}

# EC2 permissions policy
resource "aws_iam_role_policy" "ec2_permissions" {
  name = "${var.environment}-${var.function_name}-ec2-policy"
  role = aws_iam_role.dr_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion": [var.primary_region, var.dr_region]
          }
        }
      }
    ]
  })
}

# SNS permissions policy
resource "aws_iam_role_policy" "sns_permissions" {
  name = "${var.environment}-${var.function_name}-sns-policy"
  role = aws_iam_role.dr_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = [var.sns_topic_arn]
      }
    ]
  })
}

# CloudWatch Logs permissions policy
resource "aws_iam_role_policy" "cloudwatch_permissions" {
  name = "${var.environment}-${var.function_name}-cloudwatch-policy"
  role = aws_iam_role.dr_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.function_name}*:*"
        ]
      }
    ]
  })
}

# X-Ray permissions policy
resource "aws_iam_role_policy" "xray_permissions" {
  name = "${var.environment}-${var.function_name}-xray-policy"
  role = aws_iam_role.dr_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets",
          "xray:GetSamplingStatisticSummaries"
        ]
        Resource = "*"
      }
    ]
  })
}

# KMS permissions policy
resource "aws_iam_role_policy" "kms_permissions" {
  name = "${var.environment}-${var.function_name}-kms-policy"
  role = aws_iam_role.dr_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = var.kms_key_arns
        Condition = {
          StringEquals = {
            "kms:ViaService": [
              "sns.${data.aws_region.current.name}.amazonaws.com",
              "logs.${data.aws_region.current.name}.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

# EventBridge permissions policy
resource "aws_iam_role_policy" "eventbridge_permissions" {
  name = "${var.environment}-${var.function_name}-eventbridge-policy"
  role = aws_iam_role.dr_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "events:PutEvents"
        ]
        Resource = [
          "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/default"
        ]
      }
    ]
  })
}

# IAM role for cross-region access
resource "aws_iam_role" "dr_cross_region" {
  name = "${var.environment}-dr-cross-region-role"
  path = "/service-roles/dr/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Condition = {
          StringEquals = {
            "aws:PrincipalArn": aws_iam_role.dr_lambda_role.arn
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-cross-region-role"
      Purpose = "cross-region-access"
    }
  )
}

# Cross-region permissions policy
resource "aws_iam_role_policy" "cross_region_permissions" {
  name = "${var.environment}-dr-cross-region-policy"
  role = aws_iam_role.dr_cross_region.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion": var.primary_region
          }
        }
      }
    ]
  })
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
