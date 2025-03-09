module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name            = "eks-vpc"
  cidr            = var.vpc_cidr
  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.common_tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  eks_managed_node_groups = {
    general = {
      desired_size  = 2
      min_size      = 1
      max_size      = 3
      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = local.common_tags
}

resource "aws_eks_fargate_profile" "default" {
  cluster_name           = module.eks.cluster_name
  fargate_profile_name   = "default"
  pod_execution_role_arn = module.eks.fargate_pod_execution_role_arn
  subnet_ids             = module.vpc.private_subnets

  selector {
    namespace = "default"
  }
}

resource "kubernetes_helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "kube-system"

  depends_on = [module.eks]
} 

resource "aws_acm_certificate" "tls_cert" {
  domain_name       = "api.example.com"
  validation_method = "DNS"
}

resource "kubernetes_ingress_v1" "api_ingress" {
  metadata {
    name      = "api-ingress"
    namespace = "default"
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "cert-manager.io/cluster-issuer"             = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect"  = "true"
    }
  }

  spec {
    tls {
      hosts       = ["api.example.com"]
      secret_name = "tls-secret"
    }

    rule {
      host = "api.example.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "api-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

