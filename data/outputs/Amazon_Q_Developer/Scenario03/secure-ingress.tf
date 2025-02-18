# secure-ingress.tf
resource "kubernetes_ingress_v1" "api_ingress" {
  metadata {
    name      = "api-ingress"
    namespace = "default"

    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect"   = "true"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "10m"
      "nginx.ingress.kubernetes.io/proxy-buffer-size" = "128k"
    }
  }

  spec {
    tls {
      hosts       = ["api.example.com"]
      secret_name = "default-ssl-cert"
    }

    rule {
      host = "api.example.com"
      http {
        path {
          path      = "/v1"
          path_type = "Prefix"
          backend {
            service {
              name = "api-service"
              port {
                number = 8080
              }
            }
          }
        }

        path {
          path      = "/health"
          path_type = "Exact"
          backend {
            service {
              name = "api-service"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.ingress_nginx]
}

resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.cluster_security_group_id
}
