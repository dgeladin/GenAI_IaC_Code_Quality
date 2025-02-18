# fargate-profile.tf - EKS Fargate Profile Configuration

resource "aws_eks_fargate_profile" "default_namespace" {
  cluster_name           = module.eks_cluster.cluster_name
  fargate_profile_name   = "default-namespace-profile"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn

  # Subnet selection from the VPC module
  subnet_ids = module.eks_vpc.private_subnets

  # Selector for pods in the default namespace
  selector {
    namespace = "default"
  }

  # Additional selector for kube-system namespace (optional)
  selector {
    namespace = "kube-system"
    labels = {
      k8s-app = "coredns"
    }
  }

  # Tags for resource tracking
  tags = {
    Name        = "default-namespace-fargate-profile"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# IAM Role for Fargate Pod Execution
resource "aws_iam_role" "fargate_pod_execution_role" {
  name = "eks-fargate-pod-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        }
      }
    ]
  })
}

# Attach necessary AWS managed policies to the Fargate execution role
resource "aws_iam_role_policy_attachment" "fargate_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_pod_execution_role.name
}

# Output the Fargate profile name for reference
output "fargate_profile_name" {
  description = "Name of the created Fargate profile"
  value       = aws_eks_fargate_profile.default_namespace.fargate_profile_name
}