resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  stage_name  = "prod"

  depends_on = [
    aws_api_gateway_integration.example
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  # Only allow invocation from the specific API Gateway resource
  source_arn = "${aws_api_gateway_rest_api.example_api.execution_arn}/*/${aws_api_gateway_method.example.http_method}${aws_api_gateway_resource.example.path}"
}