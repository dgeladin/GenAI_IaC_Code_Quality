# Configure AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.provider_tags
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Data Source (if using existing VPC)
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# Subnet Data Source (if using existing subnets)
data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:Tier"
    values = ["private"]
  }
}

# Create Auto Scaling Group and related resources
module "asg" {
  source = "./modules/asg"  # If using modules structure

  # VPC Configuration
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # ASG Configuration
  project_name         = var.project_name
  environment         = var.environment
  service_name        = var.service_name
  min_size           = var.min_size
  max_size           = var.max_size
  desired_capacity   = var.desired_capacity

  # Instance Configuration
  instance_type      = var.instance_type
  key_name          = var.key_name
  volume_size       = var.volume_size

  # Mixed Instances Configuration
  on_demand_base_capacity                  = var.on_demand_base_capacity
  on_demand_percentage_above_base_capacity = var.on_demand_percentage
  spot_allocation_strategy                 = var.spot_allocation_strategy

  # Scaling Configuration
  cpu_target_value      = var.cpu_target_value
  memory_target_value   = var.memory_target_value
  memory_high_threshold = var.memory_high_threshold

  # Tags
  tags = local.common_tags
}
