# Blue Environment Target Group
resource "aws_lb_target_group" "blue" {
  name_prefix = "blue-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout            = 5
    interval           = 30
    path               = "/"
    port               = "traffic-port"
    protocol           = "HTTP"
    matcher            = "200"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }

  tags = merge(local.common_tags, {
    Name        = "${var.environment}-blue-tg"
    Environment = "blue"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Green Environment Target Group
resource "aws_lb_target_group" "green" {
  name_prefix = "green-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout            = 5
    interval           = 30
    path               = "/"
    port               = "traffic-port"
    protocol           = "HTTP"
    matcher            = "200"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }

  tags = merge(local.common_tags, {
    Name        = "${var.environment}-green-tg"
    Environment = "green"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Target Group Attachment (if needed for static instances)
resource "aws_lb_target_group_attachment" "blue" {
  count            = 0  # Set to desired number of static instances
  target_group_arn = aws_lb_target_group.blue.arn
  target_id        = "i-XXXXXXXXXXXXXXXXX"  # Replace with actual instance ID
  port             = 80
}

resource "aws_lb_target_group_attachment" "green" {
  count            = 0  # Set to desired number of static instances
  target_group_arn = aws_lb_target_group.green.arn
  target_id        = "i-XXXXXXXXXXXXXXXXX"  # Replace with actual instance ID
  port             = 80
}
