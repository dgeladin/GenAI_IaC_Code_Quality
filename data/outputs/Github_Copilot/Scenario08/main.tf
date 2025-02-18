provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.5.0"

  name = "example-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true

  tags = {
    Name = "example-vpc"
  }
}

resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "Example security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-sg"
  }
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
    security_groups             = [aws_security_group.example.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "ASG-Instance"
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

module "asg" {
  source = "./modules/asg"

  asg_name                                 = "example-asg"
  launch_template_id                       = aws_launch_template.example_template.id
  subnet_ids                               = module.vpc.private_subnets
  desired_capacity                         = var.desired_capacity
  min_size                                 = var.min_size
  max_size                                 = var.max_size
  on_demand_base_capacity                  = var.on_demand_base_capacity
  on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
  environment                              = var.environment
  instance_type_overrides                  = var.instance_type_overrides
  tags                                     = var.tags
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

variable "desired_capacity" {
  description = "The desired number of instances in the Auto Scaling group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "The minimum number of instances in the Auto Scaling group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of instances in the Auto Scaling group"
  type        = number
  default     = 4
}

variable "on_demand_base_capacity" {
  description = "The base capacity of On-Demand instances in the Auto Scaling group"
  type        = number
  default     = 1
}

variable "on_demand_percentage_above_base_capacity" {
  description = "The percentage of On-Demand instances above the base capacity in the Auto Scaling group"
  type        = number
  default     = 50
}

variable "environment" {
  description = "The environment for tagging purposes"
  type        = string
  default     = "development"
}

variable "instance_type_overrides" {
  description = "List of instance types and their weighted capacities for the Auto Scaling group"
  type = list(object({
    instance_type    = string
    weighted_capacity = string
  }))
  default = [
    { instance_type = "t3.micro", weighted_capacity = "1" },
    { instance_type = "t3.small", weighted_capacity = "2" }
  ]
}

variable "tags" {
  description = "Tags to apply to the Auto Scaling group instances"
  type = map(string)
  default = {
    Name        = "ASG-Instance",
    Environment = "development"
  }
}

output "example_asg_id" {
  description = "The ID of the example Auto Scaling group"
  value       = module.asg.asg_id
}