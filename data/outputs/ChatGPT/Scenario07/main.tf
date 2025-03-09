locals {
  environment = terraform.workspace
}

module "network" {
  source               = "modules/network"
  cidr_block           = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
}

module "compute" {
  source            = "modules/compute"
  environment       = local.environment
  public_subnet_ids = module.network.public_subnet_ids
  web_server_sg_id  = module.network.web_server_sg_id
}

module "database" {
  source                = "modules/database"
  environment           = local.environment
  db_name               = "app_db"
  db_username           = var.db_username
  db_password           = var.db_password
  db_instance_class     = local.environment == "production" ? "db.m5.large" : (local.environment == "staging" ? "db.t3.medium" : "db.t3.micro")
  db_allocated_storage  = 20
  db_port               = 5432
  db_subnet_group_name  = module.network.private_subnet_ids
  db_security_group_id  = module.network.database_sg_id
}

module "iam" {
  source      = "modules/iam"
  environment = local.environment
}

