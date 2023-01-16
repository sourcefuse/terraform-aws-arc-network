output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.public_subnets.az_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.private_subnets.az_subnet_ids
}

output "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  value       = module.public_subnets.az_subnet_cidr_blocks
}

output "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  value       = module.private_subnets.az_subnet_cidr_blocks
}

output "vpc_cidr" {
  description = "The VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_id" {
  description = "The VPC ID"
  value       = module.vpc.vpc_id
}

output "default_route_table_id" {
  description = "The Default Route Table ID for the VPC"
  value       = module.vpc.vpc_default_route_table_id
}

output "main_route_table_id" {
  description = "The Main Route Table ID for the VPC"
  value       = module.vpc.vpc_main_route_table_id
}
