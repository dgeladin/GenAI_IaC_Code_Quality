
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "path/to/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "your-lock-table"
  }

  required_version = ">= 1.8"
}

provider "aws" {
  region = "us-east-1"
}

locals {
  environment = terraform.workspace
}

module "network" {
  source = "../modules/network"
  environment = local.environment
}

module "compute" {
  source = "../modules/compute"
  environment = local.environment
  public_subnet_ids = module.network.public_subnet_ids
  load_balancer_sg_id = module.network.web_server_sg_id
}

module "database" {
  source = "../modules/database"
  environment = local.environment
  db_name = "exampledb"
  db_username = "admin"
  db_password = "password"
  db_instance_class = local.environment == "production" ? "db.m5.large" : local.environment == "staging" ? "db.t3.medium" : "db.t3.micro"
  db_allocated_storage = 20
  db_port = 5432
  db_subnet_group_name = module.network.db_subnet_group_name
  db_security_group_id = module.network.database_sg_id
}

module "iam" {
  source = "../modules/iam"
  environment = local.environment
}
