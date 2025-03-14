output "datadog_dashboard_url" {
  description = "URL to access the Datadog Multi-Cloud Overview dashboard"
  value       = "https://app.datadoghq.com/dashboard/${datadog_dashboard.multi_cloud_overview.id}"
}

output "aws_instance_public_ip" {
  description = "Public IP of the AWS EC2 instance"
  value       = aws_instance.example_ec2.public_ip
}

output "azure_vm_private_ip" {
  description = "Private IP of the Azure Virtual Machine"
  value       = azurerm_network_interface.example_nic.private_ip_address
}

