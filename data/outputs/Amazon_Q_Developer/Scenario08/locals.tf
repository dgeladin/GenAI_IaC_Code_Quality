locals {
  # Common tags applied at the provider level
  provider_tags = {
    ManagedBy   = "terraform"
    Environment = var.environment
    Project     = var.project_name
  }

  # Resource naming prefix
  name_prefix = "${var.project_name}-${var.environment}"

  # Common resource tags
  common_tags = merge(
    local.provider_tags,
    {
      Service     = var.service_name
      CreatedDate = timestamp()
    }
  )

  # ASG specific configurations
  asg_config = {
    min_size         = var.min_size
    max_size         = var.max_size
    desired_capacity = var.desired_capacity
  }

  # Instance type configurations for mixed instances policy
  instance_types = {
    t3_micro = {
      instance_type     = "t3.micro"
      weighted_capacity = "1"
    }
    t3_small = {
      instance_type     = "t3.small"
      weighted_capacity = "2"
    }
  }
}
