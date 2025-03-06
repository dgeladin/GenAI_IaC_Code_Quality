# helm.tf

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "kube-system"

  values = [
    <<-EOT
    controller:
      service:
        type: LoadBalancer
    EOT
  ]

  depends_on = [module.eks]
}
