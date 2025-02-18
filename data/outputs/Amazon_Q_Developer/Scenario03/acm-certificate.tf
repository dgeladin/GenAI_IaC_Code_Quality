# acm-certificate.tf
resource "aws_acm_certificate" "api_cert" {
  domain_name       = "api.example.com"  # Replace with your domain
  validation_method = "DNS"

  subject_alternative_names = ["*.api.example.com"]

  tags = {
    Environment = "production"
    Terraform   = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "api_cert" {
  certificate_arn         = aws_acm_certificate.api_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.api_cert.arn
}
