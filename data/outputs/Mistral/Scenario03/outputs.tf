# outputs.tf

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "kubectl_config" {
  description = "Kubectl configuration for the EKS cluster"
  value       = module.eks.cluster_kubeconfig
  sensitive   = true
}
