# lambda.tf

# Lambda Function
resource "aws_lambda_function" "example_lambda_function" {
  filename         = "lambda_function.zip"
  function_name    = "${var.project_name}-${var.environment}-function"
  role            = aws_iam_role.lambda_execution.arn
  handler         = "index.handler"
  runtime         = var.lambda_runtime
  
  source_code_hash = filebase64sha256("lambda_function.zip")
  publish         = true

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  # VPC Configuration (if provided)
  dynamic "vpc_config" {
    for_each = var.lambda_vpc_config != null ? [var.lambda_vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  # Environment variables
  environment {
    variables = merge(
      var.lambda_environment_variables,
      {
        ENVIRONMENT = var.environment
      }
    )
  }

  # Enable X-Ray tracing if specified
  tracing_config {
    mode = var.enable_xray_tracing ? "Active" : "PassThrough"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-function"
    }
  )
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.example_lambda_function.function_name}"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

# Lambda Function Alias for production
resource "aws_lambda_alias" "prod" {
  name             = var.environment
  description      = "Production alias for ${aws_lambda_function.example_lambda_function.function_name}"
  function_name    = aws_lambda_function.example_lambda_function.function_name
  function_version = aws_lambda_function.example_lambda_function.version

  # Enable routing configuration if specified
  dynamic "routing_config" {
    for_each = var.lambda_traffic_shifting_enabled ? [1] : []
    content {
      additional_version_weights = var.lambda_traffic_shift_percentage != null ? {
        "${var.lambda_previous_version}" = var.lambda_traffic_shift_percentage
      } : null
    }
  }
}

# Lambda Function URL (optional)
resource "aws_lambda_function_url" "url" {
  count              = var.enable_function_url ? 1 : 0
  function_name      = aws_lambda_function.example_lambda_function.function_name
  authorization_type = var.function_url_auth_type

  cors {
    allow_credentials = true
    allow_origins     = var.cors_allowed_origins
    allow_methods     = ["GET", "POST"]
    allow_headers     = ["*"]
    expose_headers    = ["keep-alive", "date"]
    max_age          = 86400
  }
}
