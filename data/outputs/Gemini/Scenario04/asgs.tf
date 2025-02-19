# Blue ASG
resource "aws_autoscaling_group" "blue_asg" {
  name               = "blue-asg"
  desired_capacity   = 2
  min_size           = 2
  max_size           = 5
  vpc_zone_identifier = module.vpc.private_subnets

  launch_template {
    id      = aws_launch_template.blue_lt.id
    version = "$Latest"
  }

  health_check_type = "EC2"  # or "ELB" if using ELB health checks
  target_group_arns = [aws_lb_target_group.blue_tg.arn]

  tag {
    key = "Environment"
    value = "blue"
  }
}

# Green ASG
resource "aws_autoscaling_group" "green_asg" {
  name               = "green-asg"
  desired_capacity   = 2
  min_size           = 2
  max_size           = 5
  vpc_zone_identifier = module.vpc.private_subnets

  launch_template {
    id      = aws_launch_template.green_lt.id
    version = "$Latest"
  }

  health_check_type = "EC2" # or "ELB" if using ELB health checks
  target_group_arns = [aws_lb_target_group.green_tg.arn]

  tag {
    key = "Environment"
    value = "green"
  }
}