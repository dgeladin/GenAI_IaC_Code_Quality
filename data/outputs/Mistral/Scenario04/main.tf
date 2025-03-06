# Define the required provider and version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.8.0"
}

provider "aws" {
  region = "us-east-1"
}

# Use the VPC module to create a VPC with public and private subnets
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "blue-green-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false
}

# Security group for the application instances
resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Allow HTTP inbound traffic from lb_sg and outbound traffic to VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

# Security group for the load balancer
resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
  description = "Allow HTTP inbound traffic from VPC and outbound traffic to app_sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
}

# Data source to get the latest Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Launch template for the blue environment
resource "aws_launch_template" "blue_launch_template" {
  name          = "blue-launch-template"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups              = [aws_security_group.app_sg.id]
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
      Name        = "blue-instance"
      Environment = "blue"
    }
  }
}

# Launch template for the green environment
resource "aws_launch_template" "green_launch_template" {
  name          = "green-launch-template"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups              = [aws_security_group.app_sg.id]
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
      Name        = "green-instance"
      Environment = "green"
    }
  }
}

# Target groups for the load balancer
resource "aws_lb_target_group" "blue_target_group" {
  name     = "blue-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "green_target_group" {
  name     = "green-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false
}

# Listener for the load balancer
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue_target_group.arn
  }
}

# Auto Scaling Group for the blue environment
resource "aws_autoscaling_group" "blue_asg" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 2
  vpc_zone_identifier  = module.vpc.public_subnets
  target_group_arns    = [aws_lb_target_group.blue_target_group.arn]
  health_check_type    = "ELB"

  launch_template {
    id      = aws_launch_template.blue_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "blue-asg"
    propagate_at_launch = true
  }
}

# Auto Scaling Group for the green environment
resource "aws_autoscaling_group" "green_asg" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 2
  vpc_zone_identifier  = module.vpc.public_subnets
  target_group_arns    = [aws_lb_target_group.green_target_group.arn]
  health_check_type    = "ELB"

  launch_template {
    id      = aws_launch_template.green_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "green-asg"
    propagate_at_launch = true
  }
}

# Output the DNS name of the load balancer
output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.app_lb.dns_name
}
