provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"  # Make sure to use the appropriate version

  name = "blue_green_vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "blue-green"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Security group for application instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Allow HTTP from lb_sg"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.lb_sg.id]
  }

  egress {
    description = "Allow all outbound traffic to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "app_sg"
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
  description = "Security group for load balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    description      = "Allow HTTP to app_sg"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.app_sg.id]
  }

  tags = {
    Name = "lb_sg"
  }
}

resource "aws_launch_template" "blue" {
  name          = "blue_lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  security_group_names = [aws_security_group.app_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello from Blue Environment" > index.html
              sudo yum install -y python3 && nohup python3 -m http.server 80 &
              EOF

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "blue_instance"
      Environment = "blue"
    }
  }
}

resource "aws_launch_template" "green" {
  name          = "green_lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  security_group_names = [aws_security_group.app_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello from Green Environment" > index.html
              sudo yum install -y python3 && nohup python3 -m http.server 80 &
              EOF

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "green_instance"
      Environment = "green"
    }
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_autoscaling_group" "blue_asg" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 2
  launch_template {
    id      = aws_launch_template.blue.id
    version = "$Latest"
  }
  vpc_zone_identifier  = module.vpc.public_subnets
  target_group_arns    = [aws_lb_target_group.blue_tg.arn]

  health_check_type    = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "blue_asg_instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "blue"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "green_asg" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 2
  launch_template {
    id      = aws_launch_template.green.id
    version = "$Latest"
  }
  vpc_zone_identifier  = module.vpc.public_subnets
  target_group_arns    = [aws_lb_target_group.green_tg.arn]

  health_check_type    = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "green_asg_instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "green"
    propagate_at_launch = true
  }
}

resource "aws_lb_target_group" "blue_tg" {
  name     = "blue_tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    port               = "80"
    protocol           = "HTTP"
    path               = "/"
    interval           = 30
    timeout            = 5
    healthy_threshold  = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "green_tg" {
  name     = "green_tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    port               = "80"
    protocol           = "HTTP"
    path               = "/"
    interval           = 30
    timeout            = 5
    healthy_threshold  = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb" "app_lb" {
  name               = "app_lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = {
    Name = "app_lb"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue_tg.arn
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "load_balancer_dns_name" {
  value = aws_lb.app_lb.dns_name
}