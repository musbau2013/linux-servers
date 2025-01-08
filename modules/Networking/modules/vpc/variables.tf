## variables.tf
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Whether to enable a NAT Gateway"
  type        = bool
  default     = false
}

variable "public_subnet_id" {
  description = "ID of the public subnet to place the NAT Gateway"
  type        = string
}
