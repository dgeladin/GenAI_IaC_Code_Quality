terraform {
  required_version = ">= 1.8.0"
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create instances based on the environment
module "instances" {
  source      = "./modules/instances"
  environment = var.environment
  ami_id      = var.ami_id
  instance_type = var.instance_type
}