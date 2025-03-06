# eks.tf

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.31"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  eks_managed_node_groups = {
    general = {
      desired_capacity = 2
      min_capacity     = 1
      max_capacity     = 3

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "dev"
    Application = "my-app"
  }
}

resource "aws_eks_fargate_profile" "default" {
  cluster_name           = module.eks.cluster_name
  fargate_profile_name   = "default"
  pod_execution_role_arn = module.eks.fargate_pod_execution_role_arn
  subnets                = module.vpc.private_subnets

  selector {
    namespace = "default"
  }
}

output "kubectl_config" {
  description = "Kubectl configuration for the EKS cluster"
  value       = module.eks.cluster_kubeconfig
  sensitive   = true
}
