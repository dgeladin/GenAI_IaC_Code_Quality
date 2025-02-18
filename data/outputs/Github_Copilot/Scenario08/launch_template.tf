provider "aws" {
  region = var.region
}

resource "aws_launch_template" "example_template" {
  name_prefix   = "example-template"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.security_group_ids
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "example-template-instance"
      Environment = var.environment
    }
  }

  user_data = base64encode(data.template_file.user_data.rendered)
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")
}

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The instance type to use for the launch template"
  type        = string
  default     = "t3.micro"
}

variable "iam_instance_profile" {
  description = "The IAM instance profile to associate with instances"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with instances"
  type        = list(string)
}

variable "environment" {
  description = "The environment for tagging purposes"
  type        = string
  default     = "development"
}