# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Or your preferred version
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# VPC and Subnets
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "blue-green-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"] # Adjust AZs as needed
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true # Optional: Enable if you need outbound internet access from private subnets
}


# Security Groups
resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Security group for application instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_group_id = aws_security_group.lb_sg.id
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
  description = "Security group for the load balancer"
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
    security_group_id = aws_security_group.app_sg.id
  }
}

# Launch Templates (in launch_templates.tf)
# Auto Scaling Groups (in asgs.tf)
# Load Balancer and Target Groups (in load_balancer.tf)

# Listener Rule (in listener.tf)

output "load_balancer_dns_name" {
  value = aws_lb.app_lb.dns_name
  description = "DNS name of the Application Load Balancer"
}