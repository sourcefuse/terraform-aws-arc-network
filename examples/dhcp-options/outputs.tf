output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.id
}

output "dhcp_options_id" {
  description = "DHCP Options Set ID"
  value       = module.vpc.dhcp_options_id
}

output "dhcp_options_arn" {
  description = "DHCP Options Set ARN"
  value       = module.vpc.dhcp_options_arn
}
