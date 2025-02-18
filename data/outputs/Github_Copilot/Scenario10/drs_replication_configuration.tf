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

data "aws_kms_key" "drs_encryption_key" {
  provider = aws.dr
  key_id   = "<your-kms-key-id>" # Replace with your KMS key ID
}

resource "aws_drs_replication_configuration_template" "example" {
  provider = aws.dr

  staging_area_subnet_id = "<your-subnet-id>" # Replace with your subnet ID
  staging_area_tags = {
    Name        = "drs-staging-area"
    Environment = "DR"
  }
  
  ebs_encryption = "CUSTOMER_MANAGED"
  kms_key_arn    = data.aws_kms_key.drs_encryption_key.arn

  source_server_tags = {
    Name        = "primary-instance"
    Environment = "Primary"
  }

  replication_server_instance_type = "t3.micro"
}

output "drs_replication_configuration_template_id" {
  value = aws_drs_replication_configuration_template.example.id
}