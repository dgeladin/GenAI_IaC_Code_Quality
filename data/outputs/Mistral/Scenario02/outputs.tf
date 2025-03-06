# outputs.tf

output "vpc_id_east" {
  description = "The ID of the VPC in the East region."
  value       = module.vpc_east.vpc_id
}

output "vpc_id_west" {
  description = "The ID of the VPC in the West region."
  value       = module.vpc_west.vpc_id
}

output "asg_name_east" {
  description = "The name of the Auto Scaling Group in the East region."
  value       = module.asg_east.asg_name
}

output "asg_name_west" {
  description = "The name of the Auto Scaling Group in the West region."
  value       = module.asg_west.asg_name
}

output "global_accelerator_arn" {
  description = "The ARN of the Global Accelerator."
  value       = module.global_accelerator.accelerator_arn
}
