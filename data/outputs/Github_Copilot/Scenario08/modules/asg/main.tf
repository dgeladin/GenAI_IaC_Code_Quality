resource "aws_autoscaling_group" "this" {
  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size
  vpc_zone_identifier = var.subnet_ids

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = var.launch_template_id
        version            = "$Latest"
      }

      dynamic "override" {
        for_each = var.instance_type_overrides
        content {
          instance_type    = override.value.instance_type
          weighted_capacity = override.value.weighted_capacity
        }
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = var.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
      spot_allocation_strategy                 = "capacity-optimized"
      spot_instance_pools                      = 2
    }
  }

  tag {
    key                 = "Name"
    value               = "ASG-Instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  scaling_policy {
    name               = "scale_up_on_low_memory"
    adjustment_type    = "ChangeInCapacity"
    scaling_adjustment = 1
    cooldown           = 300

    metric {
      namespace         = "AWS/EC2"
      name              = "MemoryUtilization"
      statistic         = "Average"
      unit              = "Percent"
      dimensions        = {
        AutoScalingGroupName = aws_autoscaling_group.this.name
      }
      period            = 60
      evaluation_periods = 1
      threshold         = 80
      comparison_operator = "GreaterThanThreshold"
    }
  }

  scaling_policy {
    name               = "scale_down_on_low_memory"
    adjustment_type    = "ChangeInCapacity"
    scaling_adjustment = -1
    cooldown           = 300

    metric {
      namespace         = "AWS/EC2"
      name              = "MemoryUtilization"
      statistic         = "Average"
      unit              = "Percent"
      dimensions        = {
        AutoScalingGroupName = aws_autoscaling_group.this.name
      }
      period            = 60
      evaluation_periods = 1
      threshold         = 20
      comparison_operator = "LessThanThreshold"
    }
  }
}

variable "launch_template_id" {
  description = "The ID of the launch template to use for the Auto Scaling group"
  type        = string
}

variable "subnet_ids" {
  description = "List of VPC subnet IDs for the Auto Scaling group"
  type        = list(string)
}

variable "desired_capacity" {
  description = "The desired number of instances in the Auto Scaling group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "The minimum number of instances in the Auto Scaling group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of instances in the Auto Scaling group"
  type        = number
  default     = 4
}

variable "on_demand_base_capacity" {
  description = "The base capacity of On-Demand instances in the Auto Scaling group"
  type        = number
  default     = 1
}

variable "on_demand_percentage_above_base_capacity" {
  description = "The percentage of On-Demand instances above the base capacity in the Auto Scaling group"
  type        = number
  default     = 50
}

variable "environment" {
  description = "The environment for tagging purposes"
  type        = string
  default     = "development"
}

variable "instance_type_overrides" {
  description = "List of instance types and their weighted capacities for the Auto Scaling group"
  type = list(object({
    instance_type    = string
    weighted_capacity = string
  }))
}

variable "tags" {
  description = "Tags to apply to the Auto Scaling group instances"
  type = map(string)
}