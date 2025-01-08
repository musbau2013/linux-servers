variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_dns_zone_name" {
  description = "Private DNS zone name"
  type        = string
}

variable "app_dns_record" {
  description = "DNS record for the app"
  type        = string
}

variable "private_ip_addresses" {
  description = "Private IPs for the DNS record"
  type        = list(string)
}
