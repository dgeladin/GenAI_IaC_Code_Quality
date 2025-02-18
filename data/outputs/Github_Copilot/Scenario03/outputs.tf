output "kubectl_config" {
  value       = module.eks.kubeconfig
  description = "Kubeconfig file content to be used by kubectl for accessing the EKS cluster"
  sensitive   = true
}