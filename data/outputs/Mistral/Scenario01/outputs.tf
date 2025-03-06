# Output the IDs of the Windows instances
output "windows_instance_ids" {
  description = "The IDs of the Windows instances"
  value       = aws_instance.windows[*].id
}

# Output the IDs of the AWS Linux instances
output "linux_instance_ids" {
  description = "The IDs of the AWS Linux instances"
  value       = aws_instance.linux[*].id
}

output "environment" {
  description = "The environment name"
  value       = var.environment
}
