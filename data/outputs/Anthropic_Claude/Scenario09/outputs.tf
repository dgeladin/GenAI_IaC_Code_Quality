# outputs.tf

output "datadog_dashboard_url" {
  description = "URL to access the Multi-Cloud Overview dashboard in Datadog"
  value       = "https://app.datadoghq.com/dashboard/${datadog_dashboard.multicloud_overview.id}"
}

output "aws_instance_id" {
  description = "ID of the AWS EC2 instance being monitored"
  value       = aws_instance.monitoring_instance.id
}

output "aws_instance_private_ip" {
  description = "Private IP address of the AWS EC2 instance"
  value       = aws_instance.monitoring_instance.private_ip
}

output "azure_vm_name" {
  description = "Name of the Azure VM being monitored"
  value       = azurerm_linux_virtual_machine.monitoring_vm.name
}

output "azure_vm_private_ip" {
  description = "Private IP address of the Azure VM"
  value       = azurerm_linux_virtual_machine.monitoring_vm.private_ip_address
}

output "datadog_monitor_aws_id" {
  description = "ID of the AWS CPU monitor in Datadog"
  value       = datadog_monitor.aws_cpu_alert.id
}

output "datadog_monitor_azure_id" {
  description = "ID of the Azure CPU monitor in Datadog"
  value       = datadog_monitor.azure_cpu_alert.id
}