terraform {
  required_version = ">= 1.8"

  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "gitops-infra/${terraform.workspace}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = "us-east-1"
}

