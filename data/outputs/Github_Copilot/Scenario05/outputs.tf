output "db_instance_endpoint" {
  description = "The endpoint of the RDS instance."
  value       = aws_db_instance.example_db.endpoint
}

output "db_instance_identifier" {
  description = "The identifier of the RDS instance."
  value       = aws_db_instance.example_db.identifier
}