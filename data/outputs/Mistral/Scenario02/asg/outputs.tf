# asg/outputs.tf

output "asg_name" {
  description = "The name of the Auto Scaling Group."
  value       = aws_autoscaling_group.example.name
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer."
  value       = aws_lb.example.arn
}
