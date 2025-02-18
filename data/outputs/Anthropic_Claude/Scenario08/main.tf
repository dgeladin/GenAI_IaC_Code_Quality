# File: main.tf
# Launch template for both On-Demand and Spot instances
resource "aws_launch_template" "example_template" {
  name_prefix   = "example-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  
  # Network configuration
  vpc_security_group_ids = var.security_group_ids
  
  # SSH key pair (if specified)
  dynamic "key_pair" {
    for_each = var.key_name != null ? [1] : []
    content {
      key_name = var.key_name
    }
  }
  
  # IAM instance profile (if specified)
  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_name != null ? [1] : []
    content {
      name = var.iam_instance_profile_name
    }
  }
  
  # Enable detailed monitoring for better scaling metrics
  monitoring {
    enabled = true
  }
  
  # Use EBS-optimized instances for better performance
  ebs_optimized = true
  
  # Block device mappings for the root volume
  block_device_mappings {
    device_name = "/dev/xvda"
    
    ebs {
      volume_size           = 20
      volume_type          = "gp3"
      delete_on_termination = true
      encrypted            = true
    }
  }
  
  # Add instance tags
  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }
  
  # Metadata options to follow security best practices
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2 required
    http_put_response_hop_limit = 1
  }
  
  lifecycle {
    create_before_destroy = true
  }
}