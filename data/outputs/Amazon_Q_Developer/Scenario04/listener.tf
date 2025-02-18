# Production Listener
resource "aws_lb_listener" "production" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-production-listener"
  })
}

# Test Listener (for testing new deployments)
resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-test-listener"
  })
}

# Listener Rule for Production Traffic
resource "aws_lb_listener_rule" "production" {
  listener_arn = aws_lb_listener.production.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-production-rule"
  })
}
