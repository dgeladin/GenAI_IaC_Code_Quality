output "db_endpoint" {
  description = "The endpoint of the database."
  value       = aws_db_instance.main.endpoint
}
