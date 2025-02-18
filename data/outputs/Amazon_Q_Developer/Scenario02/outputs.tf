output "vpc_east_id" {
  description = "ID of the East region VPC"
  value       = module.vpc_east.vpc_id
}

output "vpc_west_id" {
  description = "ID of the West region VPC"
  value       = module.vpc_west.vpc_id
}

output "private_subnets_east" {
  description = "List of private subnet IDs in East region"
  value       = module.vpc_east.private_subnets
}

output "private_subnets_west" {
  description = "List of private subnet IDs in West region"
  value       = module.vpc_west.private_subnets
}

output "public_subnets_east" {
  description = "List of public subnet IDs in East region"
  value       = module.vpc_east.public_subnets
}

output "public_subnets_west" {
  description = "List of public subnet IDs in West region"
  value       = module.vpc_west.public_subnets
}

output "alb_dns_east" {
  description = "DNS name of the East region ALB"
  value       = module.asg_east.alb_dns_name
}

output "alb_dns_west" {
  description = "DNS name of the West region ALB"
  value       = module.asg_west.alb_dns_name
}

output "global_accelerator_dns" {
  description = "DNS name of the Global Accelerator"
  value       = aws_globalaccelerator_accelerator.this.dns_name
}

output "global_accelerator_ips" {
  description = "Static IP addresses of the Global Accelerator"
  value       = aws_globalaccelerator_accelerator.this.ip_sets[0].ip_addresses
}
