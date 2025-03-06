provider "aws" {
  alias  = "dr"
  region = var.region_dr
}

resource "aws_s3_bucket" "example_dr_backup_bucket" {
  provider = aws.dr
  bucket   = "example-dr-backup-bucket"
  acl      = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "transition-and-expire-backups"
    enabled = true

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "example-dr-backup-bucket"
    Environment = "dr"
  }
}

resource "aws_s3_bucket_public_access_block" "example_dr_backup_bucket_block" {
  provider = aws.dr
  bucket   = aws_s3_bucket.example_dr_backup_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
