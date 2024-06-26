output "vpn_endpoint_dns_name" {
  value       = module.network.vpn_endpoint_dns_name
  description = "The DNS Name of the Client VPN Endpoint Connection."
}

output "public_subnet_ids" {
  value       = module.network.public_subnet_ids
  description = "public subnets per az"
}

output "private_subnet_ids" {
  value       = module.network.private_subnet_ids
  description = "private subnets per availibility zones"
}
