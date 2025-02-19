# ../modules/compute/main.tf

variable "region" {
  type = string
  description = "AWS region"
  default = "us-east-1" # Example default, adjust as needed
}

variable "environment" {
  type = string
  description = "Deployment environment (development, staging, production)"
}

variable "public_subnet_ids" {
  type = list(string)
  description = "List of public subnet IDs"
}

variable "web_server_sg_id" {
  type = string
  description = "ID of the web server security group"
}

variable "instance_type" {
  type = map(string)
  description = "Instance type per environment"
  default = {
    development = "t3.micro"
    staging     = "t3.medium"
    production  = "t3.large"
  }
}

variable "desired_capacity" {
  type = number
  description = "Desired capacity of the ASG"
  default = 2
}

variable "min_size" {
  type = number
  description = "Minimum size of the ASG"
  default = 2
}

variable "max_size" {
  type = number
  description = "Maximum size of the ASG"
  default = 5
}


data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-*"]
  }
}

resource "aws_launch_template" "web_server" {
  name_prefix   = "${var.environment}-web-server-lt-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type[var.environment]

  network_interface {
    security_groups = [var.web_server_sg_id]
  }

  tag {
    key = "Environment"
    value = var.environment
  }
}

resource "aws_autoscaling_group" "web_server" {
  name               = "${var.environment}-web-server-asg"
  desired_capacity   = var.desired_capacity
  min_size           = var.min_size
  max_size           = var.max_size
  vpc_zone_identifier = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.web_server.id
    version = "$Latest"
  }

  health_check_type = "EC2"

  tag {
    key = "Environment"
    value = var.environment
  }
}


resource "aws_lb" "web_server" {
  name               = "${var.environment}-web-server-alb"
  internal           = false # Set to true if internal
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.web_server_sg_id] # Use the web server SG

  tag {
    key = "Environment"
    value = var.environment
  }
}

resource "aws_lb_target_group" "web_server" {
  name       = "${var.environment}-web-server-tg"
  port       = 80 # Could be 443 if you terminate TLS on the ALB
  protocol   = "HTTP" # Could be HTTPS if you terminate TLS on the ALB
  vpc_id     = aws_lb.web_server.vpc_id

  tag {
    key = "Environment"
    value = var.environment
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.web_server.arn
  port              = 443
  protocol          = "HTTPS"

  # Replace with your actual certificate ARN
  certificate_arn = "arn:aws:acm:YOUR_REGION:YOUR_ACCOUNT_ID:certificate/YOUR_CERTIFICATE_ID" # Replace!

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_server.arn
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.web_server.name
  lb_target_group_arn    = aws_lb_target_group.web_server.arn
}

output "alb_dns_name" {
    value = aws_lb.web_server.dns_name
}