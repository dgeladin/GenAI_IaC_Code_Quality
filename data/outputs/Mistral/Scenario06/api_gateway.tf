# Define the API Gateway REST API
resource "aws_api_gateway_rest_api" "example_api" {
  name        = "example_api"
  description = "API Gateway for the example serverless application"
}

# Define the API Gateway resource
resource "aws_api_gateway_resource" "example" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  parent_id   = aws_api_gateway_rest_api.example_api.root_resource_id
  path_part   = "example"
}

# Define the API Gateway method
resource "aws_api_gateway_method" "example" {
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  resource_id   = aws_api_gateway_resource.example.id
  http_method   = "GET"
  authorization = "NONE"
}

# Define the API Gateway integration
resource "aws_api_gateway_integration" "example" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  resource_id  = aws_api_gateway_resource.example.id
  http_method  = aws_api_gateway_method.example.http_method
  type         = "AWS_PROXY"
  integration_http_method = "POST"
  uri          = aws_lambda_function.example_lambda_function.invoke_arn
}

# Grant API Gateway permission to invoke the Lambda function
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.example_api.execution_arn}/*/*"
}
