terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }

  required_version = ">= 1.8.0"
}

provider "aws" {
  region = "us-east-1"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.main.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

data "aws_eks_cluster" "main" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "main" {
  name = module.eks.cluster_id
}