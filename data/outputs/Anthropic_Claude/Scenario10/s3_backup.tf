# S3 bucket for DR backups
resource "aws_s3_bucket" "dr_backup" {
  bucket = var.backup_bucket_name
  
  # Prevent accidental deletion of backup bucket
  force_destroy = false

  tags = merge(
    var.common_tags,
    {
      Name = "DR Backup Bucket"
      Purpose = "Disaster Recovery Backups"
    }
  )
}

# Enable versioning
resource "aws_s3_bucket_versioning" "dr_backup_versioning" {
  bucket = aws_s3_bucket.dr_backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure private access
resource "aws_s3_bucket_public_access_block" "dr_backup_access" {
  bucket = aws_s3_bucket.dr_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Server-side encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "dr_backup_encryption" {
  bucket = aws_s3_bucket.dr_backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      kms_master_key_id = aws_kms_key.dr_key.arn
    }
  }
}

# Lifecycle rule
resource "aws_s3_bucket_lifecycle_configuration" "dr_backup_lifecycle" {
  bucket = aws_s3_bucket.dr_backup.id

  rule {
    id     = "backup_retention"
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