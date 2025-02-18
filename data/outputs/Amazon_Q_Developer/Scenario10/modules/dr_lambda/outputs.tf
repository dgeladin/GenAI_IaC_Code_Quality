output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.dr_failover.arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.dr_failover.function_name
}

output "function_version" {
  description = "Latest published version of the Lambda function"
  value       = aws_lambda_function.dr_failover.version
}

output "alias_arn" {
  description = "ARN of the Lambda function alias"
  value       = aws_lambda_alias.prod.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.lambda_dashboard.dashboard_name
}
