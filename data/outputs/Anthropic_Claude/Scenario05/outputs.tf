output "db_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.example.endpoint
}

output "db_security_group_id" {
  description = "The ID of the database security group"
  value       = aws_security_group.db_sg.id
}

output "db_subnet_group_name" {
  description = "The name of the database subnet group"
  value       = aws_db_subnet_group.example.name
}

output "migration_hash" {
  description = "Hash of the migration script"
  value       = sha256(data.template_file.migration_script.rendered)
}

output "rds_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.example.id
}

output "rds_database_name" {
  description = "The name of the database"
  value       = aws_db_instance.example.db_name
}

output "rds_port" {
  description = "The port the database is listening on"
  value       = aws_db_instance.example.port
}