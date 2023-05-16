################################################################################
## private
################################################################################
output "private_subnet_ids" {
  description = "Map of AZ names to subnet IDs"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

output "private_subnet_arns" {
  description = "Map of AZ names to subnet ARNs"
  value       = { for k, v in aws_subnet.private : k => v.arn }
}

output "private_subnet_cidr_blocks" {
  description = "Map of AZ names to subnet CIDR blocks"
  value       = { for k, v in aws_subnet.private : k => v.cidr_block }
}

output "private_route_table_ids" {
  description = " Map of AZ names to Route Table IDs"
  value       = { for k, v in aws_route_table.private : k => v.id }
}

################################################################################
## public
################################################################################
output "public_subnet_ids" {
  description = "Map of AZ names to subnet IDs"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "public_subnet_arns" {
  description = "Map of AZ names to subnet ARNs"
  value       = { for k, v in aws_subnet.public : k => v.arn }
}

output "public_subnet_cidr_blocks" {
  description = "Map of AZ names to subnet CIDR blocks"
  value       = { for k, v in aws_subnet.public : k => v.cidr_block }
}

output "public_route_table_ids" {
  description = " Map of AZ names to Route Table IDs"
  value       = { for k, v in aws_route_table.public : k => v.id }
}

output "public_ngw_ids" {
  description = "Map of AZ names to NAT Gateway IDs (only for public subnets)"
  value       = { for k, v in aws_nat_gateway.public : k => v.id }
}
