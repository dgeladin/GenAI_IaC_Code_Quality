# filename: versions.tf

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Assuming you're using S3 backend for state
  backend "s3" {
    key = "dr-automation/terraform.tfstate"
    # Other backend configuration should be provided via backend config file
  }
}