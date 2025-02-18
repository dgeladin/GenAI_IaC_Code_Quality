output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "lb_security_group_id" {
  description = "ID of the load balancer security group"
  value       = aws_security_group.lb_sg.id
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app_sg.id
}

output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.app_lb.dns_name
}

output "alb_zone_id" {
  description = "Route 53 zone ID of the load balancer"
  value       = aws_lb.app_lb.zone_id
}

output "blue_target_group_arn" {
  description = "ARN of the blue target group"
  value       = aws_lb_target_group.blue.arn
}

output "green_target_group_arn" {
  description = "ARN of the green target group"
  value       = aws_lb_target_group.green.arn
}

output "production_listener_arn" {
  description = "ARN of the production listener"
  value       = aws_lb_listener.production.arn
}

output "test_listener_arn" {
  description = "ARN of the test listener"
  value       = aws_lb_listener.test.arn
}
