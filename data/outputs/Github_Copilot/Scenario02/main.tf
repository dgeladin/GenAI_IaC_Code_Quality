# Configure the AWS provider for the us-east-1 region
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Configure the AWS provider for the us-west-2 region
provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"
}

# Call the VPC module for the us-east-1 region
module "vpc_us_east_1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  providers = {
    aws = aws.us_east_1
  }

  name = "vpc-us-east-1"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}

# Call the VPC module for the us-west-2 region
module "vpc_us_west_2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  providers = {
    aws = aws.us_west_2
  }

  name = "vpc-us-west-2"
  cidr = "10.1.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}

# Call the ASG module for the us-east-1 region
module "asg_east" {
  source = "./modules/asg"

  providers = {
    aws = aws.us_east_1
  }

  vpc_id          = module.vpc_us_east_1.vpc_id
  subnet_ids      = module.vpc_us_east_1.public_subnets
  min_size        = 2
  max_size        = 5
  desired_capacity = 2
  instance_type   = "t3.micro"
  application_name = "example-app"
}

# Call the ASG module for the us-west-2 region
module "asg_west" {
  source = "./modules/asg"

  providers = {
    aws = aws.us_west_2
  }

  vpc_id          = module.vpc_us_west_2.vpc_id
  subnet_ids      = module.vpc_us_west_2.public_subnets
  min_size        = 2
  max_size        = 5
  desired_capacity = 2
  instance_type   = "t3.micro"
  application_name = "example-app"
}

# Create the Global Accelerator
resource "aws_globalaccelerator_accelerator" "example" {
  name               = "example-accelerator"
  enabled            = true
  ip_address_type    = "IPV4"

  attributes {
    flow_logs_enabled = false
  }
}

# Create a listener for the Global Accelerator
resource "aws_globalaccelerator_listener" "example" {
  accelerator_arn = aws_globalaccelerator_accelerator.example.id
  protocol        = "TCP"
  port_ranges {
    from_port = 80
    to_port   = 80
  }
  client_affinity = "SOURCE_IP"
}

# Create endpoint groups for the Global Accelerator
resource "aws_globalaccelerator_endpoint_group" "us_east_1" {
  listener_arn = aws_globalaccelerator_listener.example.id
  endpoint_configuration {
    endpoint_id = module.asg_east.alb_arn
    weight      = 50
  }
  region = "us-east-1"
}

resource "aws_globalaccelerator_endpoint_group" "us_west_2" {
  listener_arn = aws_globalaccelerator_listener.example.id
  endpoint_configuration {
    endpoint_id = module.asg_west.alb_arn
    weight      = 50
  }
  region = "us-west-2"
}