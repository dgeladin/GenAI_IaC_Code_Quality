# File: asg.tf
# Auto Scaling group with mixed instances policy and memory-based scaling
resource "aws_autoscaling_group" "example_asg" {
  name                      = "example-asg"
  vpc_zone_identifier       = var.subnet_ids
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  capacity_rebalance        = true
  health_check_type         = "EC2"
  health_check_grace_period = 300
  
  # Mixed instances policy with refined instance distribution
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.example_template.id
        version            = "$Latest"
      }
      
      # Instance type overrides with weights
      dynamic "override" {
        for_each = var.instance_weights
        content {
          instance_type     = override.key
          weighted_capacity = override.value
        }
      }
    }
    
    # Refined instance distribution strategy
    instances_distribution {
      on_demand_base_capacity                  = var.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
      spot_allocation_strategy                 = var.spot_allocation_strategy
      spot_instance_pools                      = var.spot_allocation_strategy == "lowest-price" ? var.spot_instance_pools : null
      spot_max_price                           = ""
    }
  }
  
  # Instance maintenance policy
  instance_maintenance_policy {
    min_healthy_percentage = 90
    max_healthy_percentage = 120
  }
  
  # Warm pool configuration
  warm_pool {
    pool_state                  = "Stopped"
    min_size                    = 0
    max_group_prepared_capacity = var.max_size
    
    instance_reuse_policy {
      reuse_on_scale_in = false
    }
  }
  
  # Instance refresh configuration
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
      instance_warmup        = 300
    }
  }
  
  default_instance_warmup = 300
  
  # Termination policies
  termination_policies = [
    "AllocationStrategy",
    "OldestLaunchTemplate",
    "OldestInstance"
  ]
  
  # Dynamic tags
  dynamic "tag" {
    for_each = local.asg_tags
    content {
      key                 = tag.value.key
      value              = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }
  
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      desired_capacity,
      target_group_arns
    ]
  }
}

# CloudWatch metric alarm for high memory utilization
resource "aws_cloudwatch_metric_alarm" "high_memory_utilization" {
  alarm_name          = "high-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = var.scale_up_threshold
  alarm_description   = "This metric monitors EC2 memory utilization for scaling up"
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example_asg.name
  }
  
  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}

# CloudWatch metric alarm for low memory utilization
resource "aws_cloudwatch_metric_alarm" "low_memory_utilization" {
  alarm_name          = "low-memory-utilization"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = var.scale_down_threshold
  alarm_description   = "This metric monitors EC2 memory utilization for scaling down"
  
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example_asg.name
  }
  
  alarm_actions = [aws_autoscaling_policy.scale_down.arn]
}

# Auto Scaling policy for scaling up
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-policy"
  autoscaling_group_name = aws_autoscaling_group.example_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.scale_up_adjustment
  cooldown               = var.scaling_cooldown
}

# Auto Scaling policy for scaling down
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down-policy"
  autoscaling_group_name = aws_autoscaling_group.example_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.scale_down_adjustment
  cooldown               = var.scaling_cooldown
}