locals {
  # Instance specific tags
  instance_tags = {
    Name        = "${local.name_prefix}-instance"
    Environment = var.environment
    Role        = "web-server"
    Terraform   = "true"
    Service     = var.service_name
  }

  # ASG specific tags
  asg_tags = {
    Name             = "${local.name_prefix}-asg"
    ASGName          = "${local.name_prefix}-asg"
    AutoScalingGroup = "true"
  }

  # Launch template tags
  launch_template_tags = {
    Name    = "${local.name_prefix}-launch-template"
    Purpose = "Mixed instances ASG"
  }

  # Volume tags
  volume_tags = {
    Name        = "${local.name_prefix}-volume"
    Environment = var.environment
    Backup      = "true"
  }

  # Combined tags for resources that need all tags
  all_tags = merge(
    local.instance_tags,
    local.common_tags,
    {
      LastUpdated = timestamp()
    }
  )
}

# Tag validation
variable "required_tags" {
  description = "List of required tag keys"
  type        = list(string)
  default = [
    "Name",
    "Environment",
    "Service",
    "ManagedBy"
  ]
}

# Tag validation rule
resource "null_resource" "tag_validation" {
  lifecycle {
    precondition {
      condition = alltrue([
        for tag in var.required_tags :
        contains(keys(local.all_tags), tag)
      ])
      error_message = "Missing required tags. All resources must have the following tags: ${join(", ", var.required_tags)}"
    }
  }
}
