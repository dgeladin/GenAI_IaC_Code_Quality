# Example S3 backend configuration
# Copy this file to backend.tf and modify for your environment
terraform {
  backend "s3" {
    bucket         = "example-terraform-state"
    key            = "rds/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}