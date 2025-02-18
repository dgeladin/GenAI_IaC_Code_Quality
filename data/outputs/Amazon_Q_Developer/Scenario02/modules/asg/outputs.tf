output "asg_name" {
  description = "Name of the created Auto Scaling Group"
  value       = aws_autoscaling_group.this.name
}

output "alb_dns_name" {
  description = "DNS name of the created Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.this.arn
}
