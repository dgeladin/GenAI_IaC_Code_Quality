# Define the Auto Scaling Group
resource "aws_autoscaling_group" "example_asg" {
  name                 = "example-asg"
  vpc_zone_identifier  = var.vpc_subnets  # List of subnet IDs
  desired_capacity     = var.desired_capacity
  min_size             = var.min_size
  max_size             = var.max_size

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.example_template.id
      }

      override {
        instance_type     = "t3.micro"
        weighted_capacity = 1
      }

      override {
        instance_type     = "t3.small"
        weighted_capacity = 2
      }
    }

    instances_distribution {
      on_demand_base_capacity                 = var.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
      spot_allocation_strategy               = "capacity-optimized"
    }
  }

  tag {
    key                 = "Name"
    value               = "ASG-Instance"
    propagate_at_launch = true
  }
}
