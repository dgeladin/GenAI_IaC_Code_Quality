# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Or specify your preferred version
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "environment" {
  type    = string
  description = "The environment (dev, prod, etc.) based on Terraform workspace"
}

variable "instance_type" {
  type = map(string)
  default = {
    default = "t2.micro"
    dev     = "t2.small"
    prod    = "t2.medium"
  }
  description = "Instance types for different environments"
}

variable "ami_id" {
  type = map(string)
  description = "AMI IDs for different operating systems"
  default = {
    windows = "ami-0c94855ba95c574c8" # Example Windows AMI - Replace with your desired AMI
    linux   = "ami-0c94855ba95c574c8" # Example AWS Linux AMI - Replace with your desired AMI
  }
}

locals {
  instance_definitions = {
    windows = {
      ami           = var.ami_id["windows"]
      resource_name = "windows_instance"
    }
    linux = {
      ami           = var.ami_id["linux"]
      resource_name = "linux_instance"
    }
  }
}

module "ec2_instance" {
  for_each = local.instance_definitions

  source = "./modules/ec2"

  ami_id       = each.value.ami
  instance_type = var.instance_type[var.environment]
  count        = var.environment == "dev" ? 1 : (var.environment == "prod" && each.key == "windows" ? 2 : (var.environment == "prod" && each.key == "linux" ? 3 : 0))
  name         = each.value.resource_name
  environment  = var.environment
}

output "instance_public_ips" {
  value = { for name, module in module.ec2_instance: name => module.instance_public_ips }
  description = "Public IPs of the EC2 instances"
}