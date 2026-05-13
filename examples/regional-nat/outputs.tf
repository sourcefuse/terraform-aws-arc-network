output "vpc_id" {
  description = "VPC ID"
  value       = module.network.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "regional_nat_gateway_id" {
  description = "Regional NAT Gateway ID"
  value       = module.network.regional_nat_gateway_id
}

output "regional_nat_gateway_addresses" {
  description = "Regional NAT Gateway addresses per AZ"
  value       = module.network.regional_nat_gateway_addresses
}
