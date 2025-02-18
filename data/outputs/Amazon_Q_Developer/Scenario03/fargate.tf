# fargate.tf
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

resource "aws_iam_role_policy_attachment" "fargate_pod_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_pod_execution_role.name
}

resource "aws_eks_fargate_profile" "default" {
  cluster_name           = module.eks.cluster_name
  fargate_profile_name   = "default-fargate-profile"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
  subnet_ids            = module.vpc.private_subnets

  selector {
    namespace = "default"
    labels = {
      "fargate" = "true"
    }
  }

  selector {
    namespace = "kube-system"
  }

  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}

output "fargate_profile_arn" {
  description = "ARN of the Fargate Profile"
  value       = aws_eks_fargate_profile.default.arn
}

output "fargate_profile_status" {
  description = "Status of the Fargate Profile"
  value       = aws_eks_fargate_profile.default.status
}
