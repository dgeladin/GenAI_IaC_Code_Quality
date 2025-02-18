# Lambda function
resource "aws_lambda_function" "dr_failover" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.environment}-${var.function_name}"
  role            = var.lambda_role_arn
  handler         = "index.handler"
  runtime         = "nodejs16.x"
  timeout         = 300 # 5 minutes
  memory_size     = 256

  environment {
    variables = {
      ENVIRONMENT         = var.environment
      PRIMARY_REGION     = var.primary_region
      DR_REGION          = var.dr_region
      SNS_TOPIC_ARN      = var.sns_topic_arn
      DRS_CONFIG_ID      = var.drs_configuration_id
      CROSS_REGION_ROLE  = var.cross_region_role_arn
      LOG_LEVEL          = var.environment == "prod" ? "INFO" : "DEBUG"
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tracing_config {
    mode = "Active"
  }

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-${var.function_name}"
      Purpose = "disaster-recovery"
    }
  )

  # Prevent deployment if code hasn't changed
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # Enable versioning
  publish = true
}

# Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/files"
  output_path = "${path.module}/files/${var.function_name}.zip"
}

# Lambda alias for production
resource "aws_lambda_alias" "prod" {
  name             = "PROD"
  description      = "Production alias for DR failover function"
  function_name    = aws_lambda_function.dr_failover.function_name
  function_version = aws_lambda_function.dr_failover.version

  # Enable routing configuration for blue/green deployment
  routing_config {
    additional_version_weights = var.enable_blue_green ? {
      "${aws_lambda_function.dr_failover.version-1}" = 0.1
    } : {}
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.dr_failover.function_name}"
  retention_in_days = var.log_retention_days
  kms_key_id       = var.log_encryption_key_arn

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-${var.function_name}-logs"
      Purpose = "logging"
    }
  )
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.environment}-${var.function_name}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "Lambda function error rate monitor"
  alarm_actions      = [var.sns_topic_arn]

  dimensions = {
    FunctionName = aws_lambda_function.dr_failover.function_name
  }

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-${var.function_name}-error-alarm"
      Purpose = "monitoring"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${var.environment}-${var.function_name}-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period             = "300"
  statistic          = "Average"
  threshold          = "250000" # 250 seconds (5 minutes - 50 seconds buffer)
  alarm_description  = "Lambda function duration monitor"
  alarm_actions      = [var.sns_topic_arn]

  dimensions = {
    FunctionName = aws_lambda_function.dr_failover.function_name
  }

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-${var.function_name}-duration-alarm"
      Purpose = "monitoring"
    }
  )
}

# Lambda permission for EventBridge
resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dr_failover.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.eventbridge_rule_arn
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "lambda_dashboard" {
  dashboard_name = "${var.environment}-${var.function_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.dr_failover.function_name],
            ["AWS/Lambda", "Errors", "FunctionName", aws_lambda_function.dr_failover.function_name],
            ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.dr_failover.function_name],
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", aws_lambda_function.dr_failover.function_name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Lambda Metrics"
        }
      },
      {
        type   = "log"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          query   = "SOURCE '/aws/lambda/${aws_lambda_function.dr_failover.function_name}' | fields @timestamp, @message | sort @timestamp desc | limit 20"
          region  = data.aws_region.current.name
          title   = "Recent Lambda Logs"
        }
      }
    ]
  })
}

# Data sources
data "aws_region" "current" {}
