output "asg_id" {
  description = "The ID of the Auto Scaling group"
  value       = aws_autoscaling_group.this.id
}