# Root module - provider.tf

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Environment = local.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}