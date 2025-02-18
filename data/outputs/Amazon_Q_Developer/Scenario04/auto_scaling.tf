# Blue Auto Scaling Group
resource "aws_autoscaling_group" "blue" {
  name                = "${var.environment}-blue-asg"
  desired_capacity    = var.asg_desired_capacity
  max_size           = var.asg_max_size
  min_size           = var.asg_min_size
  target_group_arns  = [aws_lb_target_group.blue.arn]
  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type  = "ELB"
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.blue.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  dynamic "tag" {
    for_each = merge(local.common_tags, {
      Name        = "${var.environment}-blue-asg"
      Environment = "blue"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [target_group_arns]
  }
}

# Green Auto Scaling Group
resource "aws_autoscaling_group" "green" {
  name                = "${var.environment}-green-asg"
  desired_capacity    = var.asg_desired_capacity
  max_size           = var.asg_max_size
  min_size           = var.asg_min_size
  target_group_arns  = [aws_lb_target_group.green.arn]
  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type  = "ELB"
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.green.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  dynamic "tag" {
    for_each = merge(local.common_tags, {
      Name        = "${var.environment}-green-asg"
      Environment = "green"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [target_group_arns]
  }
}

# Scaling Policies - CPU Based
resource "aws_autoscaling_policy" "blue_scale_up" {
  name                   = "${var.environment}-blue-scale-up"
  autoscaling_group_name = aws_autoscaling_group.blue.name
  adjustment_type        = "ChangeInCapacity"
  policy_type           = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }
}

resource "aws_autoscaling_policy" "green_scale_up" {
  name                   = "${var.environment}-green-scale-up"
  autoscaling_group_name = aws_autoscaling_group.green.name
  adjustment_type        = "ChangeInCapacity"
  policy_type           = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }
}
