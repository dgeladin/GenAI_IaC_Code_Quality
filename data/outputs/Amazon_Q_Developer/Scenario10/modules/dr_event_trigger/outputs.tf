output "event_rule_arn" {
  description = "ARN of the CloudWatch event rule"
  value       = aws_cloudwatch_event_rule.dr_trigger.arn
}

output "event_rule_name" {
  description = "Name of the CloudWatch event rule"
  value       = aws_cloudwatch_event_rule.dr_trigger.name
}

output "composite_alarm_arn" {
  description = "ARN of the composite alarm"
  value       = aws_cloudwatch_composite_alarm.dr_trigger.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.health_notifications.arn
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.dr_health.dashboard_name
}

output "webhook_destination_arn" {
  description = "ARN of the webhook API destination"
  value       = var.enable_webhook_notification ? aws_cloudwatch_event_api_destination.notification_webhook[0].arn : null
}
