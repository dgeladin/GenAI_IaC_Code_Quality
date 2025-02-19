# modules/asg/main.tf

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "application_name" {
  type        = string
  description = "Name of the application"
}

variable "min_size" {
  type        = number
  description = "Minimum number of instances"
}

variable "max_size" {
  type        = number
  description = "Maximum number of instances"
}

variable "desired_capacity" {
  type        = number
  description = "Desired number of instances"
}


resource "aws_launch_template" "lt" {
  name_prefix   = "lt-${var.application_name}-"
  image_id      = "ami-0c94855ba95c574c8" # Replace with your desired AMI
  instance_type = var.instance_type

  user_data = base64encode(file("${path.module}/user_data.sh")) # Example user data script

  # Security groups
  vpc_security_group_ids = [aws_security_group.asg_sg.id]

  # IAM instance profile (if needed)
  # iam_instance_profile {
  #   arn = aws_iam_instance_profile.asg_profile.arn
  # }

  # ... other Launch Template configurations (e.g., key pair, block device mappings)
}


resource "aws_autoscaling_group" "asg" {
  name               = "${var.application_name}-asg"
  vpc_zone_identifier = var.subnet_ids

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.lt.id
    version = aws_launch_template.lt.latest_version
  }

  # Health checks (optional)
  # health_check_type = "ELB" # Or "EC2"
  # health_check_grace_period = 300

  # Load balancer attachments
  target_group_arns = [aws_lb_target_group.app_tg.arn]

  # ... other ASG configurations (e.g., tags, lifecycle hooks)
}

resource "aws_security_group" "asg_sg" {
  name        = "${var.application_name}-sg"
  description = "Security group for the ASG"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust as needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Adjust as needed
  }
}


resource "aws_lb" "app_lb" {
  name               = "example-app-lb"
  internal           = false # Set to true if internal
  load_balancer_type = "application"
  subnets            = var.subnet_ids

  # Security groups (optional, you can also use the ASG SG)
  # security_groups = [aws_security_group.lb_sg.id]

}

resource "aws_lb_target_group" "app_tg" {
  name               = "example-app-tg"
  port               = 80
  protocol           = "HTTP"
  vpc_id             = var.vpc_id

  health_check {
    path               = "/" # Or your application's health check path
    protocol           = "HTTP"
    matcher            = "200" # Expected HTTP response code
    interval           = 30
    timeout            = 10
    healthy_threshold  = 3
    unhealthy_threshold = 3
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  lb_target_group_arn    = aws_lb_target_group.app_tg.arn
}


output "alb_arn" {
  value       = aws_lb.app_lb.arn
  description = "ARN of the Application Load Balancer"
}