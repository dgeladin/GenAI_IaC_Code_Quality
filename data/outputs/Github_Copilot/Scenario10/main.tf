terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  alias   = "primary"
  region  = "us-west-2"
}

provider "aws" {
  alias   = "dr"
  region  = "us-east-1"
}

module "s3_backup_bucket" {
  source = "./modules/s3_backup_bucket"
}

module "primary_instance_and_volume" {
  source = "./modules/primary_instance_and_volume"
}

module "drs_replication_configuration" {
  source = "./modules/drs_replication_configuration"
}

module "dr_kms_key" {
  source = "./modules/dr_kms_key"
}

module "cloudwatch_event_rule" {
  source = "./modules/cloudwatch_event_rule"
}

module "dr_lambda_iam_role" {
  source = "./modules/dr_lambda_iam_role"
}

module "lambda_function" {
  source = "./modules/lambda_function"
}