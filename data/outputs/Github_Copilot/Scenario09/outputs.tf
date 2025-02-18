output "datadog_dashboard_url" {
  description = "URL of the Datadog dashboard for monitoring multi-cloud resources"
  value       = "https://app.datadoghq.com/dashboard/${datadog_dashboard.multi_cloud_overview.id}"
}