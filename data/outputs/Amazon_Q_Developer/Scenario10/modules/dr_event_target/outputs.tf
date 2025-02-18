output "target_id" {
  description = "ID of the CloudWatch event target"
  value       = aws_cloudwatch_event_target.dr_failover.target_id
}

output "target_arn" {
  description = "ARN of the CloudWatch event target"
  value       = aws_cloudwatch_event_target.dr_failover.arn
}

output "dlq_url" {
  description = "URL of the Dead Letter Queue"
  value       = aws_sqs_queue.dr_dlq.id
}

output "dlq_arn" {
  description = "ARN of the Dead Letter Queue"
  value       = aws_sqs_queue.dr_dlq.arn
}

output "event_target_role_arn" {
  description = "ARN of the IAM role used by the event target"
  value       = aws_iam_role.event_target.arn
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.dr_events.dashboard_name
}
