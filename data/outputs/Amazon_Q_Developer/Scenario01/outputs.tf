output "windows_instances" {
  description = "Details of Windows instances"
  value = [
    for instance in aws_instance.windows_servers : {
      id         = instance.id
      private_ip = instance.private_ip
      tags       = instance.tags
    }
  ]
}

output "linux_instances" {
  description = "Details of Linux instances"
  value = [
    for instance in aws_instance.linux_servers : {
      id         = instance.id
      private_ip = instance.private_ip
      tags       = instance.tags
    }
  ]
}

output "current_workspace" {
  description = "Current Terraform workspace"
  value       = terraform.workspace
}
