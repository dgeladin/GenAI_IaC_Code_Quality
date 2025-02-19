output "db_endpoint" {
  value = aws_db_instance.example_db.endpoint
  description = "Endpoint for connecting to the RDS instance"
}