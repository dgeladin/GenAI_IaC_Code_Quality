output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = module.compute.alb_dns_name
}

output "db_endpoint" {
  description = "Database endpoint"
  value       = module.database.db_endpoint
  sensitive   = true
}

output "db_admin_role_arn" {
  description = "ARN of the database administrator role"
  value       = module.iam.db_admin_role_arn
}

output "db_migration_role_arn" {
  description = "ARN of the database migration role"
  value       = module.iam.db_migration_role_arn
}
