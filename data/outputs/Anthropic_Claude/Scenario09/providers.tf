# providers.tf
terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Default tags applied to all AWS resources
  default_tags {
    tags = var.default_tags
  }
}

provider "azurerm" {
  features {}
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}