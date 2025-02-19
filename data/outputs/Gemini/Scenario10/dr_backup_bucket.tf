# dr_backup_bucket.tf

resource "aws_s3_bucket" "dr_backup_bucket" {
  bucket = "example-dr-backup-bucket" # Choose a unique name
  region = "us-east-1" # Explicitly set the region

  versioning {
    enabled = true
  }

  acl = "private"

  lifecycle {
    rule {
      id = "GlacierTransitionAndExpiration"

      transition {
        days          = 30
        storage_class = "GLACIER"
      }

      expiration {
        days = 90
      }
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
    Name        = "dr-backup-bucket"
    Environment = "dr"
  }
}

output "dr_backup_bucket_name" {
  value = aws_s3_bucket.dr_backup_bucket.id
  description = "Name of the DR backup bucket"
}