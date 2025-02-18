locals {
  mixed_instances_config = {
    on_demand = {
      base_capacity                  = var.on_demand_base_capacity
      percentage_above_base_capacity = var.on_demand_percentage
    }
    spot = {
      allocation_strategy = "capacity-optimized"
      instance_pools     = 2
    }
  }

  instance_requirements = {
    primary = {
      instance_type     = "t3.micro"
      weighted_capacity = "1"
    }
    secondary = {
      instance_type     = "t3.small"
      weighted_capacity = "2"
    }
  }
}

# Mixed instances policy configuration is implemented in the ASG resource
# This file serves as a central location for mixed instances related configurations

resource "aws_autoscaling_policy" "spot_rebalance" {
  name                   = "${local.name_prefix}-spot-rebalance"
  autoscaling_group_name = aws_autoscaling_group.example.name
  adjustment_type        = "ChangeInCapacity"
  policy_type           = "SimpleScaling"
  scaling_adjustment     = 1
  cooldown              = 300

  # This policy helps maintain capacity when spot instances are reclaimed
}

# Capacity rebalancing notification
resource "aws_sns_topic" "spot_rebalance" {
  name = "${local.name_prefix}-spot-rebalance"
  tags = local.common_tags
}

resource "aws_sns_topic_subscription" "spot_rebalance" {
  count     = var.notification_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.spot_rebalance.arn
  protocol  = "email"
  endpoint  = var.notification_email
}
