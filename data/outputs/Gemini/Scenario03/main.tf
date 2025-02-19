# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name = "eks-vpc"
  cidr = var.vpc_cidr
  azs  = var.availability_zones

  enable_nat_gateway   = true
  single_nat_gateway = true

  private_subnets = [
    {
      cidr_block = cidrsubnet(var.vpc_cidr, 8, 1)
      az         = var.availability_zones[0]
    },
    {
      cidr_block = cidrsubnet(var.vpc_cidr, 8, 2)
      az         = var.availability_zones[1]
    },
    {
      cidr_block = cidrsubnet(var.vpc_cidr, 8, 3)
      az         = var.availability_zones[2]
    },
  ]

  public_subnets = [
    {
      cidr_block = cidrsubnet(var.vpc_cidr, 8, 101)
      az         = var.availability_zones[0]
    },
    {
      cidr_block = cidrsubnet(var.vpc_cidr, 8, 102)
      az         = var.availability_zones[1]
    },
    {
      cidr_block = cidrsubnet(var.vpc_cidr, 8, 103)
      az         = var.availability_zones[2]
    },
  ]

  tags = {
    Name        = "eks-vpc"
    Environment = "dev"
    KubernetesCluster = var.cluster_name
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.kubernetes_version
  vpc_id                          = module.vpc.vpc_id
  private_subnets                 = module.vpc.private_subnets[*].id

  managed_node_groups = {
    general = {
      desired_capacity = var.node_group_desired_capacity
      min_size         = var.node_group_min_size
      max_size         = var.node_group_max_size
      instance_types   = var.node_group_instance_types
      capacity_type    = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "dev"
    Application = "my-app"
  }
}

resource "aws_eks_fargate_profile" "default" {
  cluster_name = module.eks.cluster_name
  name         = "default"

  pod_execution_role_arn = module.eks.fargate_pod_execution_role_arn

  selector {
    namespace = "default"
  }

  subnet_ids = module.vpc.private_subnets[*].id

  tags = {
    Name = "fargate-profile-default"
  }
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  version    = "4.8.4"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.replicaCount"
    value = "2"
  }

  depends_on = [module.eks, kubernetes_namespace.ingress]
}

data "aws_acm_certificate" "example" {
  domain   = var.acm_certificate_domain
  most_recent = true
}

resource "kubernetes_ingress" "api_ingress" {
  metadata {
    name      = "api-ingress"
    namespace = kubernetes_namespace.ingress.metadata[0].name
    annotations = {
      kubernetes.io/ingress.class = "nginx"
    }
  }

  spec {
    tls {
      hosts = [
        var.api_domain,
      ]
      secret_name = "api-tls-secret"
    }

    rule {
      host = var.api_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = var.api_service_name
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

resource "kubernetes_secret" "api_tls_secret" {
  metadata {
    name      = "api-tls-secret"
    namespace = kubernetes_namespace.ingress.metadata[0].name
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.crt" = base64decode(data.aws_acm_certificate.example.certificate_chain)
    "tls.key" = base64decode(data.aws_acm_certificate.example.private_key)
  }
}
