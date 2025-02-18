# eks-cluster.tf - EKS Cluster Configuration

module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.0"

  # Cluster Basic Configuration
  cluster_name    = "my-eks-cluster"
  cluster_version = "1.31"

  # VPC Configuration (referencing previous VPC module)
  vpc_id     = module.eks_vpc.vpc_id
  subnet_ids = module.eks_vpc.private_subnets

  # Cluster Authentication and Access
  enable_cluster_creator_admin_permissions = true

  # EKS Managed Node Group Configuration
  eks_managed_node_groups = {
    general = {
      # Node Group Scaling Configuration
      desired_size = 2
      min_size     = 1
      max_size     = 4

      # Instance Configuration
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      # Node Group Labels and Taints
      labels = {
        Environment = "production"
        NodeGroupType = "general-purpose"
      }

      # Additional Tags
      tags = {
        Name            = "general-node-group"
        Environment     = "production"
        ManagedBy       = "Terraform"
        NodePurpose     = "general-workloads"
      }
    }
  }

  # Cluster Logging Configuration
  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # Additional Cluster Tags
  tags = {
    Terraform   = "true"
    Environment = "production"
    Project     = "my-eks-cluster"
    ManagedBy   = "Terraform"
  }
}

# Outputs for EKS Cluster
output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the cluster"
  value       = module.eks_cluster.cluster_security_group_id
}

# Kubectl Configuration Output
output "kubectl_config" {
  description = "Kubectl configuration for accessing the EKS cluster"
  value       = module.eks_cluster.kubeconfig
  sensitive   = true
}