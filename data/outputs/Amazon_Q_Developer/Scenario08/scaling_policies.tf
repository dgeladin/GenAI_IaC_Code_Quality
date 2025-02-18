# Target tracking scaling policy for CPU utilization
resource "aws_autoscaling_policy" "cpu_policy" {
  name                   = "${local.name_prefix}-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.example.name
  policy_type           = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_value
  }
}

# Target tracking scaling policy for memory utilization
resource "aws_autoscaling_policy" "memory_policy" {
  name                   = "${local.name_prefix}-memory-policy"
  autoscaling_group_name = aws_autoscaling_group.example.name
  policy_type           = "TargetTrackingScaling"

  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "AutoScalingGroupName"
        value = aws_autoscaling_group.example.name
      }
      metric_name = "MemoryUtilization"
      namespace   = "AWS/EC2"
      statistic   = "Average"
    }
    target_value = var.memory_target_value
  }
}

# Step scaling policy for high memory utilization
resource "aws_autoscaling_policy" "memory_high" {
  name                   = "${local.name_prefix}-memory-high"
  autoscaling_group_name = aws_autoscaling_group.example.name
  adjustment_type        = "ChangeInCapacity"
  policy_type           = "StepScaling"

  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
    metric_interval_upper_bound = 20
  }

  step_adjustment {
    scaling_adjustment          = 2
    metric_interval_lower_bound = 20
  }
}

# CloudWatch alarm for high memory utilization
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "${local.name_prefix}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = var.memory_high_threshold
  alarm_description  = "This metric monitors EC2 memory utilization"
  alarm_actions      = [aws_autoscaling_policy.memory_high.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }
}

# Additional variables needed in variables.tf
variable "cpu_target_value" {
  type        = number
  description = "Target value for CPU utilization"
  default     = 70
}

variable "memory_target_value" {
  type        = number
  description = "Target value for memory utilization"
  default     = 70
}

variable "memory_high_threshold" {
  type        = number
  description = "Threshold for high memory utilization alarm"
  default     = 80
}

variable "notification_email" {
  type        = string
  description = "Email address for ASG notifications"
  default     = ""
}
