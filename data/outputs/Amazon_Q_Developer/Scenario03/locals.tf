# locals.tf
locals {
  cluster_name = var.cluster_name

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
    ManagedBy   = "terraform"
  }

  eks_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}
