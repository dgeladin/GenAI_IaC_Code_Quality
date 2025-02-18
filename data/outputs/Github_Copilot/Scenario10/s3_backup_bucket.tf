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
  alias   = "dr"
  region  = "us-east-1"
}

resource "aws_s3_bucket" "example_dr_backup_bucket" {
  provider = aws.dr

  bucket = "example-dr-backup-bucket"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "transition-to-glacier-and-delete"
    enabled = true

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }

  tags = {
    Name        = "example-dr-backup-bucket"
    Environment = "DR"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.example_dr_backup_bucket.bucket
}