resource "aws_autoscaling_group" "example" {
  name                = "${local.name_prefix}-asg"
  desired_capacity    = local.asg_config.desired_capacity
  max_size           = local.asg_config.max_size
  min_size           = local.asg_config.min_size
  vpc_zone_identifier = var.subnet_ids
  health_check_type   = "ELB"
  health_check_grace_period = 300
  force_delete        = true

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.example.id
        version           = "$Latest"
      }

      dynamic "override" {
        for_each = local.instance_types
        content {
          instance_type     = override.value.instance_type
          weighted_capacity = override.value.weighted_capacity
        }
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = var.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
      spot_allocation_strategy                 = "capacity-optimized"
      spot_instance_pools                      = 2
    }
  }

  # Instance refresh configuration
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup       = 300
    }
  }

  # Dynamic tags for instances
  dynamic "tag" {
    for_each = local.instance_tags
    content {
      key                 = tag.key
      value              = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes       = [desired_capacity]
  }

  depends_on = [aws_iam_role_policy_attachment.asg_policy]
}

# Scale out policy based on memory utilization
resource "aws_autoscaling_policy" "memory_policy_out" {
  name                   = "${local.name_prefix}-memory-scale-out"
  autoscaling_group_name = aws_autoscaling_group.example.name
  adjustment_type        = "ChangeInCapacity"
  policy_type           = "StepScaling"
  
  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
  }
}

# Scale in policy based on memory utilization
resource "aws_autoscaling_policy" "memory_policy_in" {
  name                   = "${local.name_prefix}-memory-scale-in"
  autoscaling_group_name = aws_autoscaling_group.example.name
  adjustment_type        = "ChangeInCapacity"
  policy_type           = "StepScaling"
  
  step_adjustment {
    scaling_adjustment          = -1
    metric_interval_upper_bound = 0
  }
}
