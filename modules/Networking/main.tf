# Root Module

## main.tf
module "vpc" {
  source             = "./modules/vpc"
  vpc_name           = var.vpc_name
  cidr_block         = var.cidr_block
  enable_nat_gateway = true
  public_subnet_id = module.subnets.public_subnet_ids[0]
}

module "subnets" {
  source                = "./modules/subnets"
  vpc_id                = module.vpc.vpc_id
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  availability_zones    = var.availability_zones
  nat_gateway_id        = module.vpc.nat_gateway_id
  enable_nat_gateway    = true
  vpc_name              = var.vpc_name
  internet_gateway_id   = module.vpc.internet_gateway_id
}












