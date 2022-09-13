output "public_subnet_cidrs" {
  value = module.public_subnets.az_subnet_cidr_blocks
}

output "private_subnet_cidrs" {
  value = module.private_subnets.az_subnet_cidr_blocks
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}
