output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.example.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.example.arn
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.example.id
}

output "launch_template_version" {
  description = "Latest version of the Launch Template"
  value       = aws_launch_template.example.latest_version
}

output "asg_mixed_instances_policy" {
  description = "Mixed instances policy configuration"
  value       = aws_autoscaling_group.example.mixed_instances_policy
}

output "security_group_id" {
  description = "ID of the security group attached to the instances"
  value       = aws_security_group.instance.id
}
