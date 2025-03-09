output "db_admin_role_arn" {
  value = aws_iam_role.db_admin_role.arn
}

output "db_migration_role_arn" {
  value = aws_iam_role.db_migration_role.arn
}

