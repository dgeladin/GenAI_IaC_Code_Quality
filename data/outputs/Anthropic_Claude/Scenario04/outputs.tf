# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

# Security Group Outputs
output "lb_security_group_id" {
  description = "ID of the load balancer security group"
  value       = aws_security_group.lb_sg.id
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app_sg.id
}

# Launch Template Outputs
output "blue_launch_template_id" {
  description = "ID of the blue environment launch template"
  value       = aws_launch_template.blue.id
}

output "green_launch_template_id" {
  description = "ID of the green environment launch template"
  value       = aws_launch_template.green.id
}

# Target Group Outputs
output "blue_target_group_arn" {
  description = "ARN of the blue target group"
  value       = aws_lb_target_group.blue.arn
}

output "green_target_group_arn" {
  description = "ARN of the green target group"
  value       = aws_lb_target_group.green.arn
}

# Auto Scaling Group Outputs
output "blue_asg_name" {
  description = "Name of the blue Auto Scaling Group"
  value       = aws_autoscaling_group.blue.name
}

output "green_asg_name" {
  description = "Name of the green Auto Scaling Group"
  value       = aws_autoscaling_group.green.name
}

# Load Balancer Outputs
output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.app_lb.dns_name
}

output "alb_arn" {
  description = "ARN of the application load balancer"
  value       = aws_lb.app_lb.arn
}

output "alb_listener_arn" {
  description = "ARN of the default ALB listener"
  value       = aws_lb_listener.front_end.arn
}

# Application URL Outputs
output "application_url" {
  description = "URL of the application load balancer"
  value       = "http://${aws_lb.app_lb.dns_name}"
}

output "blue_environment_url" {
  description = "URL for the blue environment"
  value       = "http://${aws_lb.app_lb.dns_name}/blue/"
}

output "green_environment_url" {
  description = "URL for the green environment"
  value       = "http://${aws_lb.app_lb.dns_name}/green/"
}