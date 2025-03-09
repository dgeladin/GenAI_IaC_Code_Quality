output "db_endpoint" {
  description = "RDS instance endpoint for database connection"
  value       = aws_db_instance.example_db.endpoint
}

