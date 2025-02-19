# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Or specify your desired version
    }
  }
}

# Configure AWS providers with aliases for different regions
provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

# Module for VPC creation in us-east-1
module "vpc_east" {
  source  = "terraform-aws-modules/vpc/aws" # Using a pre-built module
  version = "~> 5.0" # Or specify your desired version

  providers = {
    aws = aws.east
  }

  name = "vpc-east"
  cidr = "10.0.0.0/16"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"] # Example AZs, adjust as needed

  # Other VPC configurations as needed (e.g., subnets, NAT gateways)
  enable_nat_gateway = true # Example
  single_nat_gateway = true # Example
  number_of_availability_zones = 3

}

# Module for VPC creation in us-west-2
module "vpc_west" {
  source  = "terraform-aws-modules/vpc/aws" # Using a pre-built module
  version = "~> 5.0" # Or specify your desired version

  providers = {
    aws = aws.west
  }

  name = "vpc-west"
  cidr = "10.1.0.0/16"

  azs = ["us-west-2a", "us-west-2b", "us-west-2c"] # Example AZs, adjust as needed

  # Other VPC configurations as needed (e.g., subnets, NAT gateways)
  enable_nat_gateway = true # Example
  single_nat_gateway = true # Example
  number_of_availability_zones = 3
}

# Module for Auto Scaling Group creation
module "asg" {
  source  = "./modules/asg"
  version = "~> 1.0"

  instance_type    = "t3.micro"
  application_name = "example-app"
  min_size         = 2
  max_size         = 5
  desired_capacity = 2
}

# ASG in us-east-1
module "asg_east" {
  source  = "./modules/asg"
  version = "~> 1.0"

  providers = {
    aws = aws.east
  }

  vpc_id      = module.vpc_east.vpc_id
  subnet_ids  = module.vpc_east.public_subnets # Assuming you have public subnets
  instance_type = module.asg.instance_type
  application_name = module.asg.application_name
  min_size         = module.asg.min_size
  max_size         = module.asg.max_size
  desired_capacity = module.asg.desired_capacity
}

# ASG in us-west-2
module "asg_west" {
  source  = "./modules/asg"
  version = "~> 1.0"

  providers = {
    aws = aws.west
  }

  vpc_id      = module.vpc_west.vpc_id
  subnet_ids  = module.vpc_west.public_subnets # Assuming you have public subnets
  instance_type = module.asg.instance_type
  application_name = module.asg.application_name
  min_size         = module.asg.min_size
  max_size         = module.asg.max_size
  desired_capacity = module.asg.desired_capacity
}

# Global Accelerator
resource "aws_globalaccelerator_accelerator" "example_accelerator" {
  name    = "example-global-accelerator"
  enabled = true

  attributes {
    flow_logs_enabled = false # Set to true if you need flow logs
  }
}

# Global Accelerator Listener
resource "aws_globalaccelerator_listener" "example_listener" {
  accelerator_arn = aws_globalaccelerator_accelerator.example_accelerator.arn
  port_ranges {
    from_port = 80
    to_port   = 80
  }
  protocol      = "TCP"  # Or "UDP" if needed
  client_affinity = "NONE" # Or "SOURCE_IP" if needed
}

# Global Accelerator Endpoint Group for us-east-1
resource "aws_globalaccelerator_endpoint_group" "example_endpoint_group_east" {
  listener_arn = aws_globalaccelerator_listener.example_listener.arn
  region       = "us-east-1"

  endpoint_configurations {
    endpoint_id = module.asg_east.alb_arn # ARN of the ALB in us-east-1
    weight      = 50
  }
}

# Global Accelerator Endpoint Group for us-west-2
resource "aws_globalaccelerator_endpoint_group" "example_endpoint_group_west" {
  listener_arn = aws_globalaccelerator_listener.example_listener.arn
  region       = "us-west-2"

  endpoint_configurations {
    endpoint_id = module.asg_west.alb_arn # ARN of the ALB in us-west-2
    weight      = 50
  }
}


output "global_accelerator_dns_name" {
  value       = aws_globalaccelerator_accelerator.example_accelerator.dns_name
  description = "DNS name of the Global Accelerator"
}

output "vpc_east_id" {
  value       = module.vpc_east.vpc_id
  description = "ID of the VPC in us-east-1"
}

output "vpc_west_id" {
  value       = module.vpc_west.vpc_id
  description = "ID of the VPC in us-west-2"
}