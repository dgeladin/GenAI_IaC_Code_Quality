output "rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.dr_failover.arn
}

output "rule_name" {
  description = "Name of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.dr_failover.name
}

output "eventbridge_role_arn" {
  description = "ARN of the EventBridge IAM role"
  value       = aws_iam_role.eventbridge_role.arn
}

output "infrastructure_health_rule_arn" {
  description = "ARN of the infrastructure health rule"
  value       = aws_cloudwatch_event_rule.infrastructure_health.arn
}

output "scheduled_health_check_rule_arn" {
  description = "ARN of the scheduled health check rule"
  value       = aws_cloudwatch_event_rule.scheduled_health_check.arn
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.dr_events.dashboard_name
}
