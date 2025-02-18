
output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "web_server_sg_id" {
  value = module.network.web_server_sg_id
}

output "db_endpoint" {
  value = module.database.db_endpoint
}

output "launch_template_id" {
  value = module.compute.launch_template_id
}

output "autoscaling_group_id" {
  value = module.compute.autoscaling_group_id
}

output "load_balancer_arn" {
  value = module.compute.load_balancer_arn
}

output "target_group_arn" {
  value = module.compute.target_group_arn
}

output "db_admin_role_arn" {
  value = module.iam.db_admin_role_arn
}

output "db_migration_role_arn" {
  value = module.iam.db_migration_role_arn
}
