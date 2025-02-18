# S3 Bucket for DR backups
resource "aws_s3_bucket" "dr_backup" {
  bucket = var.bucket_name

  # Prevent accidental deletion of backup bucket
  lifecycle {
    prevent_destroy = var.environment == "prod" ? true : false
  }

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-backup"
      Purpose = "disaster-recovery-backup"
    }
  )
}

# Bucket versioning
resource "aws_s3_bucket_versioning" "dr_backup" {
  bucket = aws_s3_bucket_versioning.dr_backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "dr_backup" {
  bucket = aws_s3_bucket.dr_backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.dr_backup.arn
    }
    bucket_key_enabled = true
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "dr_backup" {
  bucket = aws_s3_bucket.dr_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy
resource "aws_s3_bucket_policy" "dr_backup" {
  bucket = aws_s3_bucket.dr_backup.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceTLSRequestsOnly"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.dr_backup.arn,
          "${aws_s3_bucket.dr_backup.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport": "false"
          }
        }
      },
      {
        Sid    = "RestrictToSpecificRegions"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.dr_backup.arn,
          "${aws_s3_bucket.dr_backup.arn}/*"
        ]
        Condition = {
          StringNotLike = {
            "aws:RequestedRegion": [var.primary_region, var.dr_region]
          }
        }
      }
    ]
  })
}

# Lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "dr_backup" {
  bucket = aws_s3_bucket.dr_backup.id

  rule {
    id     = "backup-transition"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = var.backup_retention_days
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.backup_retention_days
    }
  }
}

# KMS key for bucket encryption
resource "aws_kms_key" "dr_backup" {
  description             = "KMS key for DR backup bucket encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                 = data.aws_iam_policy_document.kms_key_policy.json

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-backup-key"
      Purpose = "s3-encryption"
    }
  )
}

# KMS key alias
resource "aws_kms_alias" "dr_backup" {
  name          = "alias/${var.environment}-dr-backup-key"
  target_key_id = aws_kms_key.dr_backup.key_id
}

# KMS key policy
data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow S3 to use the key"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
  }
}

# CloudWatch metrics and alarms
resource "aws_cloudwatch_metric_alarm" "backup_errors" {
  alarm_name          = "${var.environment}-dr-backup-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "4xxErrors"
  namespace           = "AWS/S3"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "This metric monitors S3 backup errors"

  dimensions = {
    BucketName = aws_s3_bucket.dr_backup.id
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.alarm_actions

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-backup-error-alarm"
      Purpose = "monitoring"
    }
  )
}

# S3 replication role
resource "aws_iam_role" "replication" {
  name = "${var.environment}-dr-backup-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# S3 replication policy
resource "aws_iam_role_policy" "replication" {
  name = "${var.environment}-dr-backup-replication-policy"
  role = aws_iam_role.replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [aws_s3_bucket.dr_backup.arn]
      },
      {
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Effect = "Allow"
        Resource = ["${aws_s3_bucket.dr_backup.arn}/*"]
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Effect = "Allow"
        Resource = ["${aws_s3_bucket.dr_backup.arn}/*"]
      }
    ]
  })
}

# Data sources
data "aws_caller_identity" "current" {}
