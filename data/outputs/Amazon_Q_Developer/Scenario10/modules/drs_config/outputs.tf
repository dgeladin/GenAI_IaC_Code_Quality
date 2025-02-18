output "replication_template_id" {
  description = "ID of the DRS replication template"
  value       = aws_drs_replication_configuration_template.dr_template.id
}

output "source_server_id" {
  description = "ID of the DRS source server"
  value       = aws_drs_source_server.primary.id
}

output "recovery_instance_id" {
  description = "ID of the DRS recovery instance"
  value       = aws_drs_recovery_instance.dr_instance.id
}

output "config_parameter_name" {
  description = "Name of the SSM parameter storing DRS configuration"
  value       = aws_ssm_parameter.drs_config.name
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.drs_monitoring.dashboard_name
}
