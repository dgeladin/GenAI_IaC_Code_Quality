output "vpc_us_east_1_id" {
  description = "The ID of the VPC in us-east-1 region"
  value       = module.vpc_us_east_1.vpc_id
}

output "vpc_us_west_2_id" {
  description = "The ID of the VPC in us-west-2 region"
  value       = module.vpc_us_west_2.vpc_id
}

output "asg_east_id" {
  description = "The ID of the Auto Scaling Group in us-east-1 region"
  value       = module.asg_east.aws_autoscaling_group.this.id
}

output "asg_west_id" {
  description = "The ID of the Auto Scaling Group in us-west-2 region"
  value       = module.asg_west.aws_autoscaling_group.this.id
}

output "global_accelerator_dns_name" {
  description = "The DNS name of the Global Accelerator"
  value       = aws_globalaccelerator_accelerator.example.dns_name
}