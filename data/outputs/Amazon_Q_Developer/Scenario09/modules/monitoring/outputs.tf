output "dashboard_url" {
  description = "URL of the created Datadog dashboard"
  value       = "https://app.datadog.com/dashboard/${datadog_dashboard.multicloud_overview.id}"
}

output "aws_monitor_id" {
  description = "ID of the AWS CPU monitor"
  value       = datadog_monitor.aws_cpu.id
}

output "azure_monitor_id" {
  description = "ID of the Azure CPU monitor"
  value       = datadog_monitor.azure_cpu.id
}

output "multicloud_health_monitor_id" {
  description = "ID of the multi-cloud health monitor"
  value       = datadog_monitor.multicloud_health.id
}

output "monitor_tags" {
  description = "Tags applied to the monitors"
  value       = local.common_tags
}
