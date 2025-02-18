# Filename: provider.tf
# Contains provider configuration

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Terraform   = "true"
      Project     = "Infrastructure Demo"
      Environment = terraform.workspace
    }
  }
}