# outputs.tf
output "kubectl_config" {
  description = "Kubectl configuration for accessing the EKS cluster"
  value       = module.eks.kubeconfig
  sensitive   = true
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}

output "aws_auth_configmap" {
  description = "The AWS auth configmap for cluster access configuration"
  value       = module.eks.aws_auth_configmap_yaml
  sensitive   = true
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  value       = module.eks.cluster_version
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "node_security_group_id" {
  description = "Security group ID for the node groups"
  value       = module.eks.node_security_group_id
}
