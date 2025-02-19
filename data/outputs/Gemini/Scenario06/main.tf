terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Or your preferred version
    }
  }
}

provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

# IAM Role for Lambda
resource "aws_iam_role" "serverless_lambda_role" {
  name = "serverless_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec" {
  role       = aws_iam_role.serverless_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaBasicExecutionRole"
}

# Lambda Function
data "archive_file" "lambda_function" {
  type        = "zip"
  output_path = "lambda_function.zip"
  source {
    content = file("lambda_function.js") # Path to your Lambda function code
  }
}

resource "aws_lambda_function" "example_lambda_function" {
  function_name    = "example_lambda_function"
  runtime          = "nodejs14.x"
  handler          = "index.handler"
  filename         = data.archive_file.lambda_function.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda_function.output_path)
  role             = aws_iam_role.serverless_lambda_role.arn
}

# API Gateway
resource "aws_api_gateway_rest_api" "example_api" {
  name        = "example_api"
  description = "API Gateway for example Lambda function"
}

resource "aws_api_gateway_resource" "example" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  path_part   = "example"
}

resource "aws_api_gateway_method" "example" {
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  resource_id = aws_api_gateway_resource.example.id
  http_method   = "GET"
  authorization = "NONE" # Consider adding authorization later
}

resource "aws_api_gateway_integration" "example" {
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  resource_id = aws_api_gateway_resource.example.id
  http_method   = aws_api_gateway_method.example.http_method
  integration_http_method = aws_api_gateway_method.example.http_method
  type                    = "aws_proxy"
  credentials             = null # Not required for Lambda proxy integration
  uri                     = aws_lambda_function.example_lambda_function.invoke_arn
  passthrough_behavior    = "when_no_match"
  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  stage_name = "prod"
  depends_on = [
    aws_api_gateway_integration.example
  ]
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.example_api.arn}/*/GET/example"
}

# Output the full API URL
output "api_url" {
  value = "${aws_api_gateway_deployment.example.invoke_url}${aws_api_gateway_resource.example.path}"
}