# asg.tf
variable "asg_config" {
  description = "Configuration for Auto Scaling Group"
  type = object({
    vpc_id            = string
    subnet_ids        = list(string)
    min_size          = number
    max_size          = number
    desired_capacity  = number
    instance_type     = string
    application_name  = string
  })
}

variable "ami_id" {
  description = "AMI ID for launch template"
  type        = string
}

# Security Group for Instances
resource "aws_security_group" "asg_sg" {
  name_prefix = "${var.asg_config.application_name}-asg-sg"
  vpc_id      = var.asg_config.vpc_id

  # HTTP/HTTPS ingress
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH for management (restrict in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.asg_config.application_name}-security-group"
  }
}

# Launch Template
resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "${var.asg_config.application_name}-launch-template"
  instance_type = var.asg_config.instance_type
  image_id      = var.ami_id

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.asg_sg.id]
  }

  # Optional user data for application deployment
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "Deploying ${var.asg_config.application_name}"
    # Add application deployment scripts here
  EOF
  )

  tags = {
    Name = "${var.asg_config.application_name}-launch-template"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  vpc_zone_identifier = var.asg_config.subnet_ids
  desired_capacity    = var.asg_config.desired_capacity
  max_size            = var.asg_config.max_size
  min_size            = var.asg_config.min_size

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.asg_config.application_name}-instance"
    propagate_at_launch = true
  }
}

# Scale-up Policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.asg_config.application_name}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

# Scale-down Policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.asg_config.application_name}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

# Outputs
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.name
}

output "security_group_id" {
  description = "ID of the Security Group"
  value       = aws_security_group.asg_sg.id
}