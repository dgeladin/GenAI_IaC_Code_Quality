terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Or specify your preferred version (e.g., "~> 4.0", or a specific version like "5.2.0")
    }
  }
  required_version = "~> 1.8" # Or specify your minimum Terraform version (e.g., "~> 1.5", or a specific version like "1.8.7")
}