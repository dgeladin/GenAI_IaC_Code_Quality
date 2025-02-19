# outputs.tf
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "kubectl_config" {
  value     = module.eks.kubeconfig
  sensitive = true
}

output "ingress_controller_ip" {
  value = helm_release.ingress_nginx.status.load_balancer.ingress[0].ip
  description = "IP address of the Ingress Controller LoadBalancer"
}