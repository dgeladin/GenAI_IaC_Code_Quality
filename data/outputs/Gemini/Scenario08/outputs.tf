# outputs.tf

output "asg_name" {
  value = aws_autoscaling_group.example.name
  description = "Name of the Auto Scaling Group"
}

output "launch_template_id" {
  value = aws_launch_template.example.id
  description = "ID of the Launch Template"
}

output "launch_template_latest_version" {
  value = aws_launch_template.example.latest_version
  description = "Latest version of the Launch Template"
}

# Add other outputs as needed (e.g., ASG ARN, security group IDs, etc.)