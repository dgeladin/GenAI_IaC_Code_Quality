module "vpc_east" {
  source     = "./modules/vpc"
  providers  = { aws = aws.east }
  name       = "vpc-east"
  cidr_block = "10.0.0.0/16"

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
}

module "vpc_west" {
  source     = "./modules/vpc"
  providers  = { aws = aws.west }
  name       = "vpc-west"
  cidr_block = "10.1.0.0/16"

  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]
  availability_zones   = ["us-west-2a", "us-west-2b"]
}

module "asg_east" {
  source           = "./modules/asg"
  providers        = { aws = aws.east }
  vpc_id           = module.vpc_east.vpc_id
  subnet_ids       = module.vpc_east.public_subnet_ids
  min_size         = 2
  max_size         = 5
  desired_capacity = 2
  instance_type    = "t3.micro"
  application_name = "example-app"
}

module "asg_west" {
  source           = "./modules/asg"
  providers        = { aws = aws.west }
  vpc_id           = module.vpc_west.vpc_id
  subnet_ids       = module.vpc_west.public_subnet_ids
  min_size         = 2
  max_size         = 5
  desired_capacity = 2
  instance_type    = "t3.micro"
  application_name = "example-app"
}

resource "aws_globalaccelerator_accelerator" "example" {
  name    = "example-accelerator"
  enabled = true
}

resource "aws_globalaccelerator_listener" "example" {
  accelerator_arn = aws_globalaccelerator_accelerator.example.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"

  port_ranges {
    from_port = 80
    to_port   = 80
  }
}

resource "aws_globalaccelerator_endpoint_group" "example" {
  listener_arn          = aws_globalaccelerator_listener.example.id
  endpoint_group_region = "us-east-1"

  endpoint_configuration {
    endpoint_id = module.asg_east.alb_arn
    weight      = 50
  }

  endpoint_configuration {
    endpoint_id = module.asg_west.alb_arn
    weight      = 50
  }
}

