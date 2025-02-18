# Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "${var.environment}-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets           = module.vpc.public_subnets

  enable_deletion_protection = var.enable_deletion_protection

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    prefix  = "app-lb-logs"
    enabled = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-app-lb"
  })
}

# S3 Bucket for ALB access logs
resource "aws_s3_bucket" "lb_logs" {
  bucket_prefix = "${var.environment}-lb-logs-"
  force_destroy = true

  tags = local.common_tags
}

# S3 Bucket Policy for ALB logs
resource "aws_s3_bucket_policy" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.current.id}:root"
        }
        Action = "s3:PutObject"
        Resource = [
          "${aws_s3_bucket.lb_logs.arn}/*"
        ]
      }
    ]
  })
}

# S3 Bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket versioning
resource "aws_s3_bucket_versioning" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket lifecycle rule
resource "aws_s3_bucket_lifecycle_configuration" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id

  rule {
    id     = "log_retention"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

# S3 Bucket public access block
resource "aws_s3_bucket_public_access_block" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
