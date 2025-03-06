# ingress.tf

resource "kubernetes_ingress_v1" "api_ingress" {
  metadata {
    name      = "api-ingress"
    namespace = "default"
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
    }
  }

  spec {
    rule {
      host = "api.example.com"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "my-api-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    tls {
      hosts      = ["api.example.com"]
      secret_name = "api-tls-secret"
    }
  }
}

resource "aws_acm_certificate" "api_cert" {
  domain_name       = "api.example.com"
  validation_method = "DNS"

  tags = {
    Name = "api-tls-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "kubernetes_secret_v1" "api_tls_secret" {
  metadata {
    name      = "api-tls-secret"
    namespace = "default"
  }

  data = {
    "tls.crt" = aws_acm_certificate.api_cert.certificate
    "tls.key" = aws_acm_certificate.api_cert.private_key
  }

  type = "kubernetes.io/tls"
}
