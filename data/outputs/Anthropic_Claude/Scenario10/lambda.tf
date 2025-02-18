# filename: lambda.tf

# Archive file for Lambda function
data "archive_file" "dr_failover_zip" {
  type        = "zip"
  source_file = "${path.module}/dr_failover.js"
  output_path = "${path.module}/dr_failover_function.zip"
}

# IAM role for Lambda
resource "aws_iam_role" "dr_lambda_role" {
  name = "dr-lambda-failover-role"

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

  tags = var.common_tags
}

# IAM policy for Lambda
resource "aws_iam_role_policy" "dr_lambda_policy" {
  name = "dr-lambda-failover-policy"
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
          "sns:Publish"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Lambda function
resource "aws_lambda_function" "dr_failover" {
  filename         = data.archive_file.dr_failover_zip.output_path
  function_name    = "dr-failover-handler"
  role            = aws_iam_role.dr_lambda_role.arn
  handler         = "dr_failover.handler"
  source_code_hash = data.archive_file.dr_failover_zip.output_base64sha256
  runtime         = "nodejs14.x"

  environment {
    variables = {
      DR_CONFIGURATION_ID = aws_drs_replication_configuration_template.example.id
      SNS_TOPIC_ARN      = var.notification_topic_arn
    }
  }

  timeout     = 300
  memory_size = 256

  tags = merge(
    var.common_tags,
    {
      Name = "DR-Failover-Lambda"
    }
  )
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "dr_lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.dr_failover.function_name}"
  retention_in_days = 14

  tags = var.common_tags
}