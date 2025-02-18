output "vm_id" {
  description = "ID of the created virtual machine"
  value       = azurerm_linux_virtual_machine.monitoring_vm.id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.monitoring_vm.name
}

output "public_ip" {
  description = "Public IP address of the virtual machine"
  value       = azurerm_public_ip.monitoring_pip.ip_address
}

output "private_ip" {
  description = "Private IP address of the virtual machine"
  value       = azurerm_network_interface.monitoring_nic.private_ip_address
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.monitoring_rg.name
}

output "workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.monitoring.workspace_id
}

output "action_group_id" {
  description = "ID of the Monitor Action Group"
  value       = azurerm_monitor_action_group.monitoring.id
}
