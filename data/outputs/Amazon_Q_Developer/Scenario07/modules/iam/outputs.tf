output "db_admin_role_arn" {
  description = "ARN of the database administrator role"
  value       = aws_iam_role.db_admin.arn
}

output "db_migration_role_arn" {
  description = "ARN of the database migration role"
  value       = aws_iam_role.db_migration.arn
}

output "db_admins_group_name" {
  description = "Name of the database administrators group"
  value       = aws_iam_group.db_admins.name
}
