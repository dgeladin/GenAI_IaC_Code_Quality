
variable "environment" {
  description = "The environment to deploy into"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the environment"
  type        = string
  default     = "t3.micro"
}

variable "desired_capacity" {
  description = "The desired capacity for the ASG"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "The minimum size for the ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "The maximum size for the ASG"
  type        = number
  default     = 5
}

variable "public_subnet_ids" {
  description = "The public subnet IDs"
  type        = list(string)
}

variable "load_balancer_sg_id" {
  description = "The security group ID for the load balancer"
  type        = string
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "example" {
  name_prefix   = "${var.environment}-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  tags = {
    Name        = "${var.environment}-launch-template"
    Environment = var.environment
  }
}

resource "aws_autoscaling_group" "example" {
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = var.public_subnet_ids
  health_check_type    = "EC2"
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-asg"
    propagate_at_launch = true
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb" "example" {
  name               = "${var.environment}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.load_balancer_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name        = "${var.environment}-lb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "example" {
  name     = "${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = element(var.public_subnet_ids, 0)

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.environment}-tg"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.example.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }

  tags = {
    Name        = "${var.environment}-listener"
    Environment = var.environment
  }
}

output "launch_template_id" {
  value = aws_launch_template.example.id
}

output "autoscaling_group_id" {
  value = aws_autoscaling_group.example.id
}

output "load_balancer_arn" {
  value = aws_lb.example.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.example.arn
}
