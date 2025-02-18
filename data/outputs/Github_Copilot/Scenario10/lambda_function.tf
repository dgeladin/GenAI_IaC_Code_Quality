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

resource "aws_iam_role" "lambda_execution_role" {
  name = "dr_failover_lambda_execution_role"

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
    Name        = "dr_failover_lambda_execution_role"
    Environment = "DR"
  }
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "dr_failover_lambda_execution_policy"
  description = "Policy for DR failover Lambda function execution"

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

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}

resource "aws_lambda_function" "dr_failover" {
  filename         = "dr_failover_function.zip"
  function_name    = "dr_failover"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  source_code_hash = filebase64sha256("dr_failover_function.zip")

  environment {
    variables = {
      DR_CONFIGURATION_ID = aws_drs_replication_configuration_template.example.id
    }
  }

  tags = {
    Name        = "dr_failover_lambda_function"
    Environment = "DR"
  }
}

resource "aws_cloudwatch_event_target" "dr_failover" {
  rule      = aws_cloudwatch_event_rule.dr_failover.name
  target_id = "dr_failover_lambda"
  arn       = aws_lambda_function.dr_failover.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dr_failover.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.dr_failover.arn
}

output "lambda_function_arn" {
  value = aws_lambda_function.dr_failover.arn
}