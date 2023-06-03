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

output "vpn_endpoint_arn" {
  value       = var.client_vpn_enabled ? local.vpn_endpoint_arn : null
  description = "The ARN of the Client VPN Endpoint Connection."
}

output "vpn_subnets" {
  value       = local.vpn_subnets
  description = "subnets associated with the VPN"
}

output "vpn_endpoint_dns_name" {
  value       = var.client_vpn_enabled ? local.vpn_endpoint_dns_name : null
  description = "The DNS Name of the Client VPN Endpoint Connection."
}

output "full_client_configuration" {
  description = "Client configuration including client certificate and private key"
  value       = var.client_vpn_enabled == true ? local.full_client_configuration : null
  sensitive   = true
}

output "igw_id" {
  description = "Internet gateway ID for the VPC"
  value       = module.vpc.igw_id
}

output "vpc_default_network_acl_id" {
  description = "The ID of the network ACL created by default on VPC creation"
  value       = module.vpc.vpc_default_network_acl_id
}
