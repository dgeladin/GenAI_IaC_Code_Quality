# outputs.tf
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.example.name
}

output "launch_template_id" {
  description = "ID of the launch template used by ASG"
  value       = aws_launch_template.example.id
}

