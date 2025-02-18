# outputs.tf

output "api_url" {
  description = "Complete API Gateway URL for invoking the Lambda function"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/example"
}

output "api_gateway_details" {
  description = "Details about the API Gateway deployment"
  value = {
    rest_api_id = aws_api_gateway_rest_api.example_api.id
    stage_name  = aws_api_gateway_stage.prod.stage_name
    endpoint    = aws_api_gateway_rest_api.example_api.endpoint_configuration[0].types[0]
  }
}

output "lambda_details" {
  description = "Details about the Lambda function"
  value = {
    function_name = aws_lambda_function.example_lambda_function.function_name
    function_arn  = aws_lambda_function.example_lambda_function.arn
    runtime       = aws_lambda_function.example_lambda_function.runtime
  }
  sensitive = false
}

output "cloudwatch_log_groups" {
  description = "CloudWatch Log Group information"
  value = {
    api_gateway = aws_cloudwatch_log_group.api_gateway.name
    lambda      = aws_cloudwatch_log_group.lambda_log_group.name
  }
}
