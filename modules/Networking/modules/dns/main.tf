resource "aws_route53_zone" "private" {
  name = var.private_dns_zone_name
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.private.zone_id
  name    = var.app_dns_record
  type    = "A"
  ttl     = 300
  records = var.private_ip_addresses
}

