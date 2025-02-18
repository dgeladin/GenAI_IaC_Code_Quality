# versions.tf

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure if you want to use remote state
  # backend "s3" {
  #   bucket         = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"
  #   key            = "serverless-app/terraform.tfstate"
  #   region         = "us-west-2"
  #   encrypt        = true
  #   dynamodb_table = "terraform-lock"
  # }
}
