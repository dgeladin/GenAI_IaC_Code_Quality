# filename: iam.tf

# IAM role for Lambda function
resource "aws_iam_role" "dr_lambda_role" {
  name = "dr-lambda-failover-role"
  description = "Role for DR failover Lambda function execution"
  
  # Allow Lambda service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "DR-Lambda-Role"
      Purpose = "Disaster Recovery"
    }
  )
}

# Attach AWS managed policy for Lambda basic execution
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.dr_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy for DR operations
resource "aws_iam_role_policy" "dr_lambda_permissions" {
  name = "dr-lambda-failover-permissions"
  role = aws_iam_role.dr_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "drs:StartRecoveryJob",
          "drs:DescribeSourceServers",
          "drs:GetReplicationConfiguration",
          "drs:DescribeRecoveryInstances",
          "drs:TagResource"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = [
          var.notification_topic_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [
          aws_kms_key.dr_key.arn
        ]
      }
    ]
  })
}

# CloudWatch Logs policy
resource "aws_iam_role_policy" "lambda_logging" {
  name = "dr-lambda-logging"
  role = aws_iam_role.dr_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:*:*:log-group:/aws/lambda/dr-failover-*:*"
        ]
      }
    ]
  })
}

# Output the role ARN for reference
output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.dr_lambda_role.arn
}

# Output the role name for reference
output "lambda_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.dr_lambda_role.name
}