# datadog.tf

# AWS EC2 CPU Monitor
resource "datadog_monitor" "aws_cpu_alert" {
  name    = "AWS EC2 High CPU Usage Alert"
  type    = "metric alert"
  message = <<-EOT
    CPU usage on AWS EC2 instance ${aws_instance.monitoring_instance.id} is too high.
    
    Instance Details:
    * Instance ID: {{host.name}}
    * Region: ${var.aws_region}
    * Current CPU: {{value}}%
    
    Please investigate the high CPU usage.
    
    @slack-ops-team
  EOT

  query = "avg(last_5m):avg:aws.ec2.cpu{instance-id:${aws_instance.monitoring_instance.id}} > ${var.cpu_critical_threshold}"

  monitor_thresholds {
    critical          = var.cpu_critical_threshold
    warning           = var.cpu_warning_threshold
    critical_recovery = var.cpu_critical_recovery
    warning_recovery  = var.cpu_warning_recovery
  }

  include_tags = true
  
  notification_preset_name = "show_all"

  tags = [
    "provider:aws",
    "env:${var.environment}",
    "service:compute",
    "terraform:true"
  ]
}

# Azure VM CPU Monitor
resource "datadog_monitor" "azure_cpu_alert" {
  name    = "Azure VM High CPU Usage Alert"
  type    = "metric alert"
  message = <<-EOT
    CPU usage on Azure VM ${azurerm_linux_virtual_machine.monitoring_vm.name} is too high.
    
    VM Details:
    * VM Name: ${azurerm_linux_virtual_machine.monitoring_vm.name}
    * Resource Group: ${azurerm_resource_group.monitoring_rg.name}
    * Location: ${var.azure_location}
    * Current CPU: {{value}}%
    
    Please investigate the high CPU usage.
    
    @slack-ops-team
  EOT

  query = "avg(last_5m):avg:azure.vm.percentage_cpu{resource_group:${azurerm_resource_group.monitoring_rg.name},name:${azurerm_linux_virtual_machine.monitoring_vm.name}} > ${var.cpu_critical_threshold}"

  monitor_thresholds {
    critical          = var.cpu_critical_threshold
    warning           = var.cpu_warning_threshold
    critical_recovery = var.cpu_critical_recovery
    warning_recovery  = var.cpu_warning_recovery
  }

  include_tags = true
  
  notification_preset_name = "show_all"

  tags = [
    "provider:azure",
    "env:${var.environment}",
    "service:compute",
    "terraform:true"
  ]
}