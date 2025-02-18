resource "kubernetes_helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.0.6"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  depends_on = [
    module.eks
  ]
}