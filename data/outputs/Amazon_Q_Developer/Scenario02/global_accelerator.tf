# Global Accelerator
resource "aws_globalaccelerator_accelerator" "this" {
  name            = "example-app-accelerator"
  ip_address_type = "IPV4"
  enabled         = true

  attributes {
    flow_logs_enabled   = true
    flow_logs_s3_bucket = aws_s3_bucket.flow_logs.id
    flow_logs_s3_prefix = "flow-logs/"
  }

  tags = {
    Name = "example-app-accelerator"
  }
}

# Global Accelerator Listener
resource "aws_globalaccelerator_listener" "this" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }
}

# Endpoint Group for East Region
resource "aws_globalaccelerator_endpoint_group" "east" {
  listener_arn = aws_globalaccelerator_listener.this.id
  
  endpoint_group_region = var.primary_region
  health_check_port    = 80
  health_check_protocol = "HTTP"
  health_check_path     = "/"

  endpoint_configuration {
    endpoint_id = module.asg_east.alb_arn
    weight     = 50
  }
}

# Endpoint Group for West Region
resource "aws_globalaccelerator_endpoint_group" "west" {
  listener_arn = aws_globalaccelerator_listener.this.id
  
  endpoint_group_region = var.secondary_region
  health_check_port    = 80
  health_check_protocol = "HTTP"
  health_check_path     = "/"

  endpoint_configuration {
    endpoint_id = module.asg_west.alb_arn
    weight     = 50
  }
}

# S3 Bucket for Flow Logs
resource "aws_s3_bucket" "flow_logs" {
  bucket_prefix = "global-accelerator-flow-logs-"
}

# S3 Bucket versioning
resource "aws_s3_bucket_versioning" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket public access block
resource "aws_s3_bucket_public_access_block" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket policy for Global Accelerator
resource "aws_s3_bucket_policy" "flow_logs" {
  bucket = aws_s3_bucket.flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowGlobalAcceleratorFlowLogs"
        Effect = "Allow"
        Principal = {
          Service = "globalaccelerator.amazonaws.com"
        }
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.flow_logs.arn}/*"
      }
    ]
  })
}
