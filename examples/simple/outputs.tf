output "vpn_endpoint_dns_name" {
  value       = module.network.vpn_endpoint_dns_name
  description = "The DNS Name of the Client VPN Endpoint Connection."
}

output "vpc_name" {
  value       = "${var.namespace}-${var.environment}-vpc"
  description = "The DNS Name of the Client VPN Endpoint Connection."
}
