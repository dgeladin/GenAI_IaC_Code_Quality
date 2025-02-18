# main.tf
module "asg_east" {
  source = "./modules/asg"
  
  ami_id = data.aws_ami.amazon_linux_2.id
  
  asg_config = {
    vpc_id            = module.vpc_east.vpc_id
    subnet_ids        = module.vpc_east.public_subnets
    min_size          = 2
    max_size          = 5
    desired_capacity  = 2
    instance_type     = "t3.micro"
    application_name  = "example-app"
  }

  providers = {
    aws = aws.east
  }
}

module "alb_east" {
  source = "./modules/alb"

  application_name   = "example-app"
  vpc_id            = module.vpc_east.vpc_id
  subnet_ids        = module.vpc_east.public_subnets
  security_group_id = module.asg_east.security_group_id

  providers = {
    aws = aws.east
  }
}

module "asg_west" {
  source = "./modules/asg"
  
  ami_id = data.aws_ami.amazon_linux_2.id
  
  asg_config = {
    vpc_id            = module.vpc_west.vpc_id
    subnet_ids        = module.vpc_west.public_subnets
    min_size          = 2
    max_size          = 5
    desired_capacity  = 2
    instance_type     = "t3.micro"
    application_name  = "example-app"
  }

  providers = {
    aws = aws.west
  }
}

module "alb_west" {
  source = "./modules/alb"

  application_name   = "example-app"
  vpc_id            = module.vpc_west.vpc_id
  subnet_ids        = module.vpc_west.public_subnets
  security_group_id = module.asg_west.security_group_id

  providers = {
    aws = aws.west
  }
}

# AMI Lookup Data Source
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}