output "zone_id" {
  value = aws_route53_zone.private.zone_id
}

output "dns_record" {
  value = aws_route53_record.app.name
}


