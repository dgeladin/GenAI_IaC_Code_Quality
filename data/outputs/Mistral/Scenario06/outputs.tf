# Output the API Gateway URL
output "api_url" {
  description = "The URL of the API Gateway endpoint"
  value       = "${aws_api_gateway_deployment.example.invoke_url}/${aws_api_gateway_resource.example.path_part}"
}
