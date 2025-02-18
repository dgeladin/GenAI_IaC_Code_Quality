provider "aws" {
  region = var.region
}

resource "aws_autoscaling_group" "example_asg" {
  launch_template {
    id      = aws_launch_template.example_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.subnet_ids

  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.example_template.id
        version            = "$Latest"
      }

      override {
        instance_type    = "t3.micro"
        weighted_capacity = "1"
      }

      override {
        instance_type    = "t3.small"
        weighted_capacity = "2"
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
    value               = "example-asg-instance"
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
}

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
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