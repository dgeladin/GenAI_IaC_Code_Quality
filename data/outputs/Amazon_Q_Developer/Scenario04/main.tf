# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = [for i in range(3) : cidrsubnet(var.vpc_cidr, 4, i)]
  public_subnets  = [for i in range(3) : cidrsubnet(var.vpc_cidr, 4, i + 3)]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  # VPC Flow Logs
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = merge(local.common_tags, {
    Name = "${var.environment}-vpc"
  })

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "Tier"                           = "Private"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    "Tier"                   = "Public"
  }
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${var.environment}-vpc-flow-logs"
  retention_in_days = 30

  tags = merge(local.common_tags, {
    Name = "${var.environment}-vpc-flow-logs"
  })
}
