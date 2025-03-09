output "api_gateway_invoke_url" {
  description = "Invoke URL for the deployed API Gateway"
  value       = "${aws_api_gateway_deployment.example.invoke_url}/${var.resource_path}"
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.example_api.execution_arn
}

