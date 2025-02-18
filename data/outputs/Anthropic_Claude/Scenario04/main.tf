# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "AmazonLinux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = [for i, az in var.azs : cidrsubnet(var.vpc_cidr, 4, i)]
  public_subnets  = [for i, az in var.azs : cidrsubnet(var.vpc_cidr, 4, i + length(var.azs))]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# Security Groups
resource "aws_security_group" "lb_sg" {
  name_prefix = "${var.environment}-lb-sg"
  description = "Security group for load balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow HTTP inbound from VPC CIDR"
  }

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
    description     = "Allow HTTP outbound to application instances"
  }

  tags = {
    Name        = "${var.environment}-lb-sg"
    Environment = var.environment
    Terraform   = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "app_sg" {
  name_prefix = "${var.environment}-app-sg"
  description = "Security group for application instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
    description     = "Allow HTTP inbound from load balancer"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "all"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow all outbound traffic to VPC CIDR"
  }

  tags = {
    Name        = "${var.environment}-app-sg"
    Environment = var.environment
    Terraform   = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Launch Templates
resource "aws_launch_template" "blue" {
  name_prefix   = "${var.environment}-blue-template"
  image_id      = data.aws_ami.AmazonLinux2.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.app_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello from Blue Environment" > index.html
              sudo yum install -y python3 && nohup python3 -m http.server 80 &
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.environment}-blue-instance"
      Environment = "blue"
      Terraform   = "true"
    }
  }

  tags = {
    Name        = "${var.environment}-blue-template"
    Environment = "blue"
    Terraform   = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "green" {
  name_prefix   = "${var.environment}-green-template"
  image_id      = data.aws_ami.AmazonLinux2.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.app_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello from Green Environment" > index.html
              sudo yum install -y python3 && nohup python3 -m http.server 80 &
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.environment}-green-instance"
      Environment = "green"
      Terraform   = "true"
    }
  }

  tags = {
    Name        = "${var.environment}-green-template"
    Environment = "green"
    Terraform   = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Target Groups
resource "aws_lb_target_group" "blue" {
  name_prefix = "blue-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  
  health_check {
    path                = "/index.html"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Name        = "${var.environment}-blue-tg"
    Environment = "blue"
    Terraform   = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "green" {
  name_prefix = "green-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  
  health_check {
    path                = "/index.html"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Name        = "${var.environment}-green-tg"
    Environment = "green"
    Terraform   = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Groups
resource "aws_autoscaling_group" "blue" {
  name                = "${var.environment}-blue-asg"
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  target_group_arns   = [aws_lb_target_group.blue.arn]
  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type   = "ELB"
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.blue.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value              = "${var.environment}-blue-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value              = "blue"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [target_group_arns]
  }
}

resource "aws_autoscaling_group" "green" {
  name                = "${var.environment}-green-asg"
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  target_group_arns   = [aws_lb_target_group.green.arn]
  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type   = "ELB"
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = aws_launch_template.green.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value              = "${var.environment}-green-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value              = "green"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [target_group_arns]
  }
}

# Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "${var.environment}-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets           = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = {
    Name        = "${var.environment}-app-lb"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Front-end Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  tags = {
    Name        = "${var.environment}-front-end-listener"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Listener Rules
resource "aws_lb_listener_rule" "blue" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  condition {
    path_pattern {
      values = ["/blue/*"]
    }
  }
}

resource "aws_lb_listener_rule" "green" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }

  condition {
    path_pattern {
      values = ["/green/*"]
    }
  }
}