terraform {
  required_version = ">= 1.8"
}

provider "aws" {
  region = "us-west-2"  # Specify your desired AWS region
}

module "asg" {
  source = "./asg"

  # Pass variables to the ASG module
  vpc_subnets                          = var.vpc_subnets
  desired_capacity                     = var.desired_capacity
  min_size                             = var.min_size
  max_size                             = var.max_size
  on_demand_base_capacity              = var.on_demand_base_capacity
  on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
}
