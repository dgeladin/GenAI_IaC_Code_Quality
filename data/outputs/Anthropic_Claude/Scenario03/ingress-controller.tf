# ingress-controller.tf - Nginx Ingress Controller Helm Release

resource "helm_release" "nginx_ingress" {
  # Helm Release Basic Configuration
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

  # Helm Chart Source
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.0"  # Specify a stable version

  # Ensure Helm release depends on EKS cluster
  depends_on = [module.eks_cluster]

  # Helm Chart Values Configuration
  values = [
    yamlencode({
      controller = {
        # LoadBalancer Configuration
        service = {
          type = "LoadBalancer"
          
          # Annotations for AWS LoadBalancer Controller
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
          }
        }

        # Resource Allocation
        resources = {
          requests = {
            cpu = "100m"
            memory = "90Mi"
          }
          limits = {
            cpu = "500m"
            memory = "256Mi"
          }
        }

        # Replica Configuration
        replicaCount = 2

        # Probes and Configuration
        config = {
          "use-forwarded-headers" = "true"
          "proxy-body-size" = "50m"
        }
      }

      # Prometheus Metrics (Optional)
      metrics = {
        enabled = true
        serviceMonitor = {
          enabled = true
        }
      }
    })
  ]

  # Tags for Resource Tracking
  set {
    name  = "tags.ManagedBy"
    value = "Terraform"
  }
}

# Outputs for Ingress Controller
output "ingress_controller_name" {
  description = "Name of the Nginx Ingress Controller release"
  value       = helm_release.nginx_ingress.name
}

output "ingress_controller_namespace" {
  description = "Namespace of the Nginx Ingress Controller"
  value       = helm_release.nginx_ingress.namespace
}