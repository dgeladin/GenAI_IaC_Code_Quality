# Filename: outputs.tf
# Contains all output declarations

output "current_workspace" {
  description = "The current Terraform workspace"
  value       = terraform.workspace
}

output "selected_instance_type" {
  description = "The instance type selected for the current workspace"
  value       = var.instance_type[terraform.workspace]
}

output "instance_ids" {
  description = "IDs of all created instances"
  value = concat(
    aws_instance.windows_instances[*].id,
    aws_instance.linux_instances[*].id
  )
}

output "windows_instance_count" {
  description = "Number of Windows instances created"
  value       = length(aws_instance.windows_instances)
}

output "linux_instance_count" {
  description = "Number of Linux instances created"
  value       = length(aws_instance.linux_instances)
}