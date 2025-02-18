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

  backend "s3" {
    # Configure your backend settings here
    # bucket = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"
    # key    = "multicloud-monitoring/terraform.tfstate"
    # region = "us-east-1"
    # encrypt = true
  }
}
