resource "aws_api_gateway_rest_api" "example_api" {
  name        = "example_api"
  description = "API Gateway for example Lambda function"
}

resource "aws_api_gateway_resource" "example" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  parent_id   = aws_api_gateway_rest_api.example_api.root_resource_id
  path_part   = "example"
}

resource "aws_api_gateway_method" "example_get" {
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  resource_id   = aws_api_gateway_resource.example.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "example" {
  rest_api_id             = aws_api_gateway_rest_api.example_api.id
  resource_id             = aws_api_gateway_resource.example.id
  http_method             = aws_api_gateway_method.example_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_invoke_arn
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = [aws_api_gateway_integration.example]
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  stage_name  = "prod"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.example_api.execution_arn}/*/*"
}

output "api_invoke_url" {
  value = aws_api_gateway_deployment.example.invoke_url
}

variable "lambda_function_invoke_arn" {
  description = "The invoke ARN of the Lambda function"
  type        = string
}

variable "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  type        = string
}