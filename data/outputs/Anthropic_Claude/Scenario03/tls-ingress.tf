# tls-ingress.tf - Secure Ingress Configuration with TLS

# Data source to fetch the ACM certificate
data "aws_acm_certificate" "api_certificate" {
  domain   = "api.yourdomain.com"
  statuses = ["ISSUED"]
}

# Kubernetes Ingress Resource for API Endpoints
resource "kubernetes_ingress_v1" "api_ingress" {
  metadata {
    name      = "api-secure-ingress"
    namespace = "default"

    annotations = {
      # Nginx Ingress Controller Annotations
      "kubernetes.io/ingress.class"                    = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"

      # AWS-specific Load Balancer Annotations
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" = data.aws_acm_certificate.api_certificate.arn
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" = "https"
    }
  }

  spec {
    # TLS Configuration
    tls {
      hosts = ["api.yourdomain.com"]
      secret_name = "api-tls-secret"
    }

    # Routing Rules
    rule {
      host = "api.yourdomain.com"
      
      http {
        # Example path-based routing
        path {
          path = "/users"
          path_type = "Prefix"
          
          backend {
            service {
              name = "users-service"
              port {
                number = 80
              }
            }
          }
        }

        path {
          path = "/products"
          path_type = "Prefix"
          
          backend {
            service {
              name = "products-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  # Depends on Helm release to ensure Ingress Controller is ready
  depends_on = [helm_release.nginx_ingress]
}

# Optional: Kubernetes Secret for TLS (if not using ACM)
resource "kubernetes_secret_v1" "api_tls_secret" {
  metadata {
    name      = "api-tls-secret"
    namespace = "default"
  }

  type = "kubernetes.io/tls"

  data = {
    # Placeholder for TLS certificate and key
    # In practice, these would be your actual certificate and key
    "tls.crt" = file("path/to/tls.crt")
    "tls.key" = file("path/to/tls.key")
  }
}

# Outputs for TLS Ingress Configuration
output "ingress_host" {
  description = "Hostname for the secured API endpoint"
  value       = kubernetes_ingress_v1.api_ingress.spec[0].rule[0].host
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate used for TLS"
  value       = data.aws_acm_certificate.api_certificate.arn
  sensitive   = true
}