# outputs.tf - Consolidated Outputs

# VPC Outputs
output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.eks_vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.eks_vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.eks_vpc.public_subnets
}

# EKS Cluster Outputs
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks_cluster.cluster_endpoint
  sensitive   = true
}

output "cluster_certificate_authority" {
  description = "Cluster certificate authority data"
  value       = module.eks_cluster.cluster_certificate_authority_data
  sensitive   = true
}

# Fargate Profile Outputs
output "fargate_profile_name" {
  description = "Name of the Fargate profile"
  value       = aws_eks_fargate_profile.default_namespace.fargate_profile_name
}

# Ingress Controller Outputs
output "ingress_controller_name" {
  description = "Name of the Nginx Ingress Controller"
  value       = helm_release.nginx_ingress.name
}

output "ingress_controller_namespace" {
  description = "Namespace of the Nginx Ingress Controller"
  value       = helm_release.nginx_ingress.namespace
}

# TLS Ingress Outputs
output "ingress_host" {
  description = "Hostname for the secured API endpoint"
  value       = kubernetes_ingress_v1.api_ingress.spec[0].rule[0].host
}