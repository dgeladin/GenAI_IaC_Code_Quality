# asg.tf
resource "aws_autoscaling_group" "blue_asg" {
  desired_capacity     = 2
  min_size            = 2
  max_size            = 5
  vpc_zone_identifier = module.vpc.public_subnets
  target_group_arns   = [aws_lb_target_group.blue_tg.arn]

  launch_template {
    id      = aws_launch_template.blue_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_group" "green_asg" {
  desired_capacity     = 2
  min_size            = 2
  max_size            = 5
  vpc_zone_identifier = module.vpc.public_subnets
  target_group_arns   = [aws_lb_target_group.green_tg.arn]

  launch_template {
    id      = aws_launch_template.green_lt.id
    version = "$Latest"
  }
}
