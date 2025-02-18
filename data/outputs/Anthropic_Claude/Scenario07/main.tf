# Root module - main.tf

terraform {
  required_version = ">= 1.8.0"
  
  backend "s3" {
    # This will be configured via backend config files for each environment
  }
}

# Get current workspace name to use as environment
locals {
  environment = terraform.workspace
  
  # Environment-specific configurations
  db_config = {
    dev = {
      db_name     = "devdb"
      db_password = var.db_password_dev
    }
    staging = {
      db_name     = "stagingdb"
      db_password = var.db_password_staging
    }
    prod = {
      db_name     = "proddb"
      db_password = var.db_password_prod
    }
  }
}

module "network" {
  source = "modules/network"
  
  environment          = local.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "compute" {
  source = "modules/compute"
  
  environment      = local.environment
  vpc_id           = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  web_server_sg_id = module.network.web_server_sg_id
  
  depends_on = [module.network]
}

module "database" {
  source = "modules/database"
  
  environment          = local.environment
  vpc_id               = module.network.vpc_id
  db_name              = lookup(local.db_config[local.environment], "db_name", "defaultdb")
  db_username          = var.db_username
  db_password          = lookup(local.db_config[local.environment], "db_password", "")
  db_subnet_ids        = module.network.private_subnet_ids
  db_security_group_id = module.network.database_sg_id
  
  depends_on = [module.network]
}

module "iam" {
  source = "modules/iam"
  
  environment    = local.environment
  db_instance_arn = module.database.db_endpoint
  project_name   = var.project_name
  
  depends_on = [module.database]
}
