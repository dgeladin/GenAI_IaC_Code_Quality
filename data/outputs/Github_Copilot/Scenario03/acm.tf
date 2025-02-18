resource "aws_acm_certificate" "tls_cert" {
  domain_name       = "your-domain.com"
  validation_method = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.tls_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = "your_zone_id"

  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "tls_cert_validation" {
  certificate_arn         = aws_acm_certificate.tls_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}