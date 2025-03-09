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

