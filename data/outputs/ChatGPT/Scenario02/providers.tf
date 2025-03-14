terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "east"
  region = var.region_east
}

provider "aws" {
  alias  = "west"
  region = var.region_west
}

