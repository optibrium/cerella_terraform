#
# @author GDev
# @date November 2021
#

resource "aws_acm_certificate" "star" {
  domain_name               = var.domain
  subject_alternative_names = ["*.${var.domain}"]
  validation_method         = "DNS"

  tags = {
    Name = var.cluster-name
  }
}

resource "aws_acm_certificate_validation" "star" {
  certificate_arn         = aws_acm_certificate.star.arn
  validation_record_fqdns = [for record in aws_route53_record.star_validation : record.fqdn]
}

resource "aws_route53_record" "star_validation" {
  for_each = {
    for dvo in aws_acm_certificate.star.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted-zone-id
}
