output "datadog_dashboard_url" {
  description = "The URL of the Datadog dashboard for multi-cloud overview."
  value       = "https://app.datadoghq.com/dashboard/${datadog_dashboard.multi_cloud_overview.id}"
}
