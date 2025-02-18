# vpc.tf - VPC Configuration for EKS Cluster

module "eks_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  # VPC Basic Configuration
  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  # Availability Zones Configuration
  azs = ["us-west-2a", "us-west-2b", "us-west-2c"]

  # Subnet Configurations
  private_subnets = [
    "10.0.1.0/24",   # Private Subnet 1
    "10.0.2.0/24",   # Private Subnet 2
    "10.0.3.0/24"    # Private Subnet 3
  ]
  public_subnets = [
    "10.0.101.0/24", # Public Subnet 1
    "10.0.102.0/24", # Public Subnet 2
    "10.0.103.0/24"  # Public Subnet 3
  ]

  # NAT Gateway Configuration
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  # Subnet Tagging for Kubernetes
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kube:purpose"                    = "private-subnet"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kube:purpose"           = "public-subnet"
  }

  # VPC Tags
  tags = {
    Terraform   = "true"
    Environment = "production"
    Project     = "eks-cluster"
    ManagedBy   = "Terraform"
  }
}

# Outputs for VPC Module
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.eks_vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.eks_vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.eks_vpc.public_subnets
}