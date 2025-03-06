terraform {
  required_version = ">= 1.8"

  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "path/to/your/terraform.tfstate"
    region = "us-west-2"
  }
}

locals {
  environment = terraform.workspace
}

module "network" {
  source      = "modules/network"
  environment = local.environment
}

module "compute" {
  source      = "modules/compute"
  environment = local.environment
}

module "database" {
  source      = "modules/database"
  environment = local.environment
}
