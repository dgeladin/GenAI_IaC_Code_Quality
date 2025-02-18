output "api_url" {
  description = "URL of the deployed API Gateway endpoint"
  value       = "${aws_api_gateway_deployment.example.invoke_url}/${aws_api_gateway_resource.example.path_part}"
}