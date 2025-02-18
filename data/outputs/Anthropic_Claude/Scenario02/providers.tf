# providers.tf
terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Providers with Regional Configuration
provider "aws" {
  region = "us-east-1"
  alias  = "east"
}

provider "aws" {
  region = "us-west-2"
  alias  = "west"
}

# Variables for VPC Configuration
variable "east_vpc_cidr" {
  description = "CIDR block for East region VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "west_vpc_cidr" {
  description = "CIDR block for West region VPC"
  type        = string
  default     = "10.1.0.0/16"
}

# VPC Module for East Region
module "vpc_east" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  providers = {
    aws = aws.east
  }

  name = "east-region-vpc"
  cidr = var.east_vpc_cidr

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Region      = "us-east-1"
  }
}

# VPC Module for West Region
module "vpc_west" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  providers = {
    aws = aws.west
  }

  name = "west-region-vpc"
  cidr = var.west_vpc_cidr

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Region      = "us-west-2"
  }
}

# Outputs for VPC Details
output "east_vpc_id" {
  description = "ID of the East region VPC"
  value       = module.vpc_east.vpc_id
}

output "west_vpc_id" {
  description = "ID of the West region VPC"
  value       = module.vpc_west.vpc_id
}