# Root module - outputs.tf

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.network.private_subnet_ids
}

output "web_server_sg_id" {
  description = "ID of web server security group"
  value       = module.network.web_server_sg_id
}

output "database_sg_id" {
  description = "ID of database security group"
  value       = module.network.database_sg_id
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.compute.alb_dns_name
}

output "db_endpoint" {
  description = "The connection endpoint for the database"
  value       = module.database.db_endpoint
  sensitive   = true
}

output "db_admin_role_arn" {
  description = "ARN of the DB administrator role"
  value       = module.iam.db_admin_role_arn
}

output "db_migration_role_arn" {
  description = "ARN of the DB migration role"
  value       = module.iam.db_migration_role_arn
}