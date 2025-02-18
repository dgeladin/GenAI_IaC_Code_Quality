# api_gateway.tf

# REST API Gateway
resource "aws_api_gateway_rest_api" "example_api" {
  name = "${var.project_name}-api"
  description = "REST API for serverless application"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = local.common_tags
}

# API Resource
resource "aws_api_gateway_resource" "example" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  parent_id   = aws_api_gateway_rest_api.example_api.root_resource_id
  path_part   = local.api_path
}

# HTTP Method
resource "aws_api_gateway_method" "example" {
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  resource_id   = aws_api_gateway_resource.example.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.X-Request-ID" = false
  }
}

# Lambda Integration
resource "aws_api_gateway_integration" "example" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.example_lambda_function.invoke_arn

  timeout_milliseconds = 29000 # 29 seconds, just under Lambda's 30-second limit
}

# Method Response
resource "aws_api_gateway_method_response" "example" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# Integration Response
resource "aws_api_gateway_integration_response" "example" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method
  status_code = aws_api_gateway_method_response.example.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.example
  ]
}

# Deployment
resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.example,
      aws_api_gateway_method.example,
      aws_api_gateway_integration.example,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.example,
    aws_api_gateway_integration.example,
    aws_api_gateway_method_response.example,
    aws_api_gateway_integration_response.example
  ]
}

# Stage
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id  = aws_api_gateway_rest_api.example_api.id
  stage_name   = var.environment

  xray_tracing_enabled = var.enable_xray_tracing

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId       = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      responseLength = "$context.responseLength"
      errorMessage   = "$context.error.message"
    })
  }

  tags = local.common_tags
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}/${var.environment}"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

# API Gateway Account Settings
resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
}
