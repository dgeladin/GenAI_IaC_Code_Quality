
# outputs.tf
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.compute.asg_name
}

output "launch_template_id" {
  description = "ID of the launch template used by ASG"
  value       = module.compute.launch_template_id
}

output "asg_security_group_id" {
  description = "ID of the ASG security group"
  value       = module.compute.asg_security_group_id
}

