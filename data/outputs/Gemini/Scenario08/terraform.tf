# terraform.tf

# Data source for Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }
}

# Launch Template
resource "aws_launch_template" "example" {
  name        = "example-template"
  description = "Launch template for mixed instances ASG"

  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type_on_demand

  # Security Groups
  vpc_security_group_ids = var.security_group_ids

  # IAM Instance Profile
  iam_instance_profile {
    arn = var.iam_instance_profile_arn
  }

  # User data (example)
  user_data = base64encode("#!/bin/bash\necho 'Hello, World!' > /tmp/hello.txt")
}

# Auto Scaling Group
resource "aws_autoscaling_group" "example" {
  name               = "example-asg"
  desired_capacity   = var.desired_capacity
  min_size           = var.min_size
  max_size           = var.max_size
  vpc_zone_identifier = var.subnet_ids

  mixed_instances_policy {
    launch_template {
      id      = aws_launch_template.example.id
      version = "$Latest"
    }

    instances_distribution {
      on_demand_base_capacity                  = var.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
      spot_allocation_strategy                 = "capacity-optimized"
    }

    override {
      instance_type     = var.instance_type_spot1
      weighted_capacity = var.spot_weight_1
    }

    override {
      instance_type     = var.instance_type_spot2
      weighted_capacity = var.spot_weight_2
    }
  }

  tag {
    key                 = "Name"
    value               = "ASG-Instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


# Example Scaling Policy (Scale up on high CPU utilization)
resource "aws_autoscaling_policy" "scale_up_cpu" {
  name                   = "scale-up-cpu"
  autoscaling_group_name = aws_autoscaling_group.example.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization" # Or a custom metric
    }
    target_value = var.target_cpu_utilization_up # Target CPU utilization (adjust as needed)
  }
}

# Example Scaling Policy (Scale down on low CPU utilization)
resource "aws_autoscaling_policy" "scale_down_cpu" {
  name                   = "scale-down-cpu"
  autoscaling_group_name = aws_autoscaling_group.example.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization" # Or a custom metric
    }
    target_value = var.target_cpu_utilization_down # Target CPU utilization (adjust as needed)
  }
}