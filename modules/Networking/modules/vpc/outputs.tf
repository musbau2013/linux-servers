output "vpc_id" {
  value = aws_vpc.main.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat[0].id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.main.id
}
