# main.tf

terraform {
  required_version = ">= 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "path/to/your/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

module "vpc_east" {
  source = "./vpc"
  providers = {
    aws = aws.east
  }
  cidr_block = "10.0.0.0/16"
  region     = "us-east-1"
}

module "vpc_west" {
  source = "./vpc"
  providers = {
    aws = aws.west
  }
  cidr_block = "10.1.0.0/16"
  region     = "us-west-2"
}

module "asg_east" {
  source = "./asg"
  providers = {
    aws = aws.east
  }
  vpc_id             = module.vpc_east.vpc_id
  public_subnet_ids  = module.vpc_east.public_subnet_ids
  min_size           = 2
  max_size           = 5
  desired_capacity   = 2
  instance_type      = "t3.micro"
  application_name   = "example-app"
}

module "asg_west" {
  source = "./asg"
  providers = {
    aws = aws.west
  }
  vpc_id             = module.vpc_west.vpc_id
  public_subnet_ids  = module.vpc_west.public_subnet_ids
  min_size           = 2
  max_size           = 5
  desired_capacity   = 2
  instance_type      = "t3.micro"
  application_name   = "example-app"
}

module "global_accelerator" {
  source = "./global_accelerator"
  endpoint_ids = [
    module.asg_east.alb_arn,
    module.asg_west.alb_arn
  ]
}
