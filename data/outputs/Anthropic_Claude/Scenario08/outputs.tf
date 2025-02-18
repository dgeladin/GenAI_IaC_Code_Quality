# File: outputs.tf
output "launch_template_id" {
  description = "The ID of the created launch template"
  value       = aws_launch_template.example_template.id
}

output "autoscaling_group_id" {
  description = "The ID of the created Auto Scaling Group"
  value       = aws_autoscaling_group.example_asg.id
}

output "autoscaling_group_arn" {
  description = "The ARN of the created Auto Scaling Group"
  value       = aws_autoscaling_group.example_asg.arn
}

output "instance_weights" {
  description = "The instance weights used in the Auto Scaling Group"
  value       = var.instance_weights
}

output "capacity_type" {
  description = "Whether the ASG is using instance count or weighted capacity units"
  value       = var.capacity_unit
}

output "scale_up_policy_arn" {
  description = "ARN of the scale up policy"
  value       = aws_autoscaling_policy.scale_up.arn
}

output "scale_down_policy_arn" {
  description = "ARN of the scale down policy"
  value       = aws_autoscaling_policy.scale_down.arn
}

output "high_memory_alarm_arn" {
  description = "ARN of the high memory utilization alarm"
  value       = aws_cloudwatch_metric_alarm.high_memory_utilization.arn
}

output "low_memory_alarm_arn" {
  description = "ARN of the low memory utilization alarm"
  value       = aws_cloudwatch_metric_alarm.low_memory_utilization.arn
}