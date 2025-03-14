output "vpc_east_id" {
  description = "VPC ID for the East region"
  value       = module.vpc_east.vpc_id
}

output "vpc_west_id" {
  description = "VPC ID for the West region"
  value       = module.vpc_west.vpc_id
}

output "asg_east_id" {
  description = "Auto Scaling Group ID for the East region"
  value       = module.asg_east.asg_id
}

output "asg_west_id" {
  description = "Auto Scaling Group ID for the West region"
  value       = module.asg_west.asg_id
}

output "global_accelerator_arn" {
  description = "ARN of the Global Accelerator"
  value       = aws_globalaccelerator_accelerator.example.id
}

