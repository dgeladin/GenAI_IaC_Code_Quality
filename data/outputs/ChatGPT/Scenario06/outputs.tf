output "lambda_function_arn" {
  description = "ARN of the deployed Lambda function"
  value       = module.lambda.lambda_function_arn
}

output "api_gateway_invoke_url" {
  description = "Invoke URL for the deployed API Gateway"
  value       = module.api_gateway.api_gateway_invoke_url
}

