provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.default_tags
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}
