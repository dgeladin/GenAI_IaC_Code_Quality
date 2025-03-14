resource "aws_s3_bucket" "backup_bucket" {
  provider = aws.dr
  bucket   = "example-dr-backup-bucket"

  tags = {
    Name        = "example-dr-backup-bucket"
    Environment = "disaster-recovery"
  }
}

resource "aws_s3_bucket_versioning" "backup_versioning" {
  provider = aws.dr
  bucket   = aws_s3_bucket.backup_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backup_lifecycle" {
  provider = aws.dr
  bucket   = aws_s3_bucket.backup_bucket.id

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }
}

