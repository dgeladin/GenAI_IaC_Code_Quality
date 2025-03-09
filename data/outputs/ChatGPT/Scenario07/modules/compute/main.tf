terraform {
  required_version = ">= 1.8"
}

variable "ami" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = "ami-12345678"  # Replace with a valid AMI ID or fetch dynamically
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "load_balancer_sg_id" {
  description = "Security group ID for the load balancer"
  type        = string
}

resource "aws_launch_template" "web_server" {
  name_prefix   = "${terraform.workspace}-web-server-"
  image_id      = var.ami
  instance_type = var.instance_type

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${terraform.workspace}-web-server"
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity     = 2
  min_size            = 2
  max_size            = 5
  vpc_zone_identifier = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.web_server.id
    version = "$Latest"
  }

  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "${terraform.workspace}-asg"
    propagate_at_launch = true
  }
}

resource "aws_lb" "web_alb" {
  name               = "${terraform.workspace}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.load_balancer_sg_id]
  subnets           = var.public_subnet_ids
}

resource "aws_lb_target_group" "web_tg" {
  name     = "${terraform.workspace}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_launch_template.web_server.vpc_id
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.web_alb.dns_name
}

