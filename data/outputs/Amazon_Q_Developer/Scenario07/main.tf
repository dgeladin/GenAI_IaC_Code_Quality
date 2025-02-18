terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Configure your backend settings here
    bucket         = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = terraform.workspace
      ManagedBy   = "Terraform"
    }
  }
}

locals {
  environment = terraform.workspace
}

module "network" {
  source = "./modules/network"

  environment = local.environment
  project    = var.project_name
  # Add other variables as needed
}

module "compute" {
  source = "./modules/compute"

  environment         = local.environment
  project            = var.project_name
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  web_server_sg_id   = module.network.web_server_sg_id
  ssl_certificate_arn = var.ssl_certificate_arn

  depends_on = [module.network]
}

module "database" {
  source = "./modules/database"

  environment        = local.environment
  project           = var.project_name
  vpc_id            = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  web_server_sg_id  = module.network.web_server_sg_id
  
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = var.db_instance_class

  depends_on = [module.network]
}

module "iam" {
  source = "./modules/iam"

  environment     = local.environment
  project        = var.project_name
  db_instance_arn = module.database.db_instance_arn
  db_resource_id  = module.database.db_resource_id

  depends_on = [module.database]
}
