locals {
  common_tags = {
    Project     = "BlueGreenDeployment"
    Environment = var.environment
    Terraform   = "true"
    ManagedBy   = "Terraform"
  }

  # Load balancer configuration
  lb_name = "${var.environment}-app-lb"

  # Target group names
  blue_tg_name  = "${var.environment}-blue-tg"
  green_tg_name = "${var.environment}-green-tg"

  # Health check settings
  health_check_settings = {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout            = 5
    interval           = 30
    path              = "/"
    port              = "traffic-port"
  }
}
