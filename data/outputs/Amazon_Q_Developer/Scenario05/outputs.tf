# Database Instance Outputs
output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.example.id
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.example.arn
}

output "db_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.example.endpoint
}

output "db_port" {
  description = "The database port"
  value       = aws_db_instance.example.port
}

output "db_name" {
  description = "The database name"
  value       = aws_db_instance.example.db_name
}

# Security Group Outputs
output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.db_sg.id
}

output "security_group_arn" {
  description = "The ARN of the security group"
  value       = aws_security_group.db_sg.arn
}

# Subnet Group Outputs
output "db_subnet_group_id" {
  description = "The ID of the DB subnet group"
  value       = aws_db_subnet_group.example.id
}

output "db_subnet_group_arn" {
  description = "The ARN of the DB subnet group"
  value       = aws_db_subnet_group.example.arn
}

# Migration Outputs
output "migration_status" {
  description = "Status of the database migration"
  value       = aws_ssm_parameter.migration_state.value
}

# Monitoring Role Outputs
output "monitoring_role_arn" {
  description = "The ARN of the monitoring IAM role"
  value       = aws_iam_role.rds_monitoring_role.arn
}

# Parameter Group Outputs
output "parameter_group_id" {
  description = "The ID of the DB parameter group"
  value       = aws_db_parameter_group.example.id
}

# Tags Output
output "resource_tags" {
  description = "Tags applied to the resources"
  value       = local.common_tags
}
