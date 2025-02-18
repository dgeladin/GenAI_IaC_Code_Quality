# East Region VPC
module "vpc_east" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "vpc-east"
  cidr = var.vpc_cidr_east

  azs             = ["${var.primary_region}a", "${var.primary_region}b", "${var.primary_region}c"]
  private_subnets = [for i in range(3) : cidrsubnet(var.vpc_cidr_east, 4, i)]
  public_subnets  = [for i in range(3) : cidrsubnet(var.vpc_cidr_east, 4, i + 3)]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  enable_vpn_gateway     = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Region = var.primary_region
  }
}

# West Region VPC
module "vpc_west" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  providers = {
    aws = aws.west
  }

  name = "vpc-west"
  cidr = var.vpc_cidr_west

  azs             = ["${var.secondary_region}a", "${var.secondary_region}b", "${var.secondary_region}c"]
  private_subnets = [for i in range(3) : cidrsubnet(var.vpc_cidr_west, 4, i)]
  public_subnets  = [for i in range(3) : cidrsubnet(var.vpc_cidr_west, 4, i + 3)]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  enable_vpn_gateway     = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Region = var.secondary_region
  }
}

# East Region ASG
module "asg_east" {
  source = "./modules/asg"

  vpc_id      = module.vpc_east.vpc_id
  subnet_ids  = module.vpc_east.public_subnets
  app_name    = "example-app"
  environment = "production"
  region_name = "east"

  min_size         = 2
  max_size         = 5
  desired_capacity = 2
  instance_type    = "t3.micro"
}

# West Region ASG
module "asg_west" {
  source = "./modules/asg"

  providers = {
    aws = aws.west
  }

  vpc_id      = module.vpc_west.vpc_id
  subnet_ids  = module.vpc_west.public_subnets
  app_name    = "example-app"
  environment = "production"
  region_name = "west"

  min_size         = 2
  max_size         = 5
  desired_capacity = 2
  instance_type    = "t3.micro"
}
