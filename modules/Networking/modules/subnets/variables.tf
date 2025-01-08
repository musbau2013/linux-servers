## variables.tf
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "nat_gateway_id" {
  description = "NAT Gateway ID for private subnets"
  type        = string
  default     = null
}

variable "enable_nat_gateway" {
  description = "Whether to enable a NAT Gateway"
  type        = bool
  default     = false
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID for public subnets"
  type        = string
}
