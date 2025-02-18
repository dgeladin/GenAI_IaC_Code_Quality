# global_accelerator.tf
resource "aws_globalaccelerator_accelerator" "app_accelerator" {
  name            = "example-app-global-accelerator"
  ip_address_type = "IPV4"
  enabled         = true

  attributes {
    flow_logs_enabled   = true
    flow_logs_s3_bucket = aws_s3_bucket.flow_logs_bucket.id
  }

  tags = {
    Name = "example-app-global-accelerator"
  }
}

resource "aws_globalaccelerator_listener" "app_listener" {
  accelerator_arn = aws_globalaccelerator_accelerator.app_accelerator.id
  
  protocol = "TCP"
  port_range {
    from_port = 80
    to_port   = 80
  }

  client_affinity = "NONE"
}

resource "aws_globalaccelerator_endpoint_group" "east_group" {
  listener_arn = aws_globalaccelerator_listener.app_listener.id
  
  endpoint_configuration {
    endpoint_id = module.alb_east.alb_arn
    weight      = 50
  }

  provider = aws.east
}

resource "aws_globalaccelerator_endpoint_group" "west_group" {
  listener_arn = aws_globalaccelerator_listener.app_listener.id
  
  endpoint_configuration {
    endpoint_id = module.alb_west.alb_arn
    weight      = 50
  }

  provider = aws.west
}

# S3 Bucket for Global Accelerator Flow Logs
resource "aws_s3_bucket" "flow_logs_bucket" {
  bucket        = "example-app-global-accelerator-logs"
  force_destroy = true
}

# Outputs
output "global_accelerator_dns" {
  description = "DNS name of the Global Accelerator"
  value       = aws_globalaccelerator_accelerator.app_accelerator.dns_name
}