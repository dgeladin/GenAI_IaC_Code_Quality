terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Region should be specified via AWS_REGION environment variable
  # or via terraform.tfvars
  region = var.aws_region

  default_tags {
    tags = local.provider_tags
  }
}
