output "id" {
  description = "The VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = [for key, value in local.internet_gw_routes : aws_subnet.this[key].id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = [for key, value in local.nat_gw_routes : aws_subnet.this[key].id]
}

output "vpc_cidr" {
  description = "The VPC CIDR block"
  value       = aws_vpc.this.cidr_block
}

output "default_route_table_id" {
  description = "The Default Route Table ID for the VPC"
  value       = aws_vpc.this.default_route_table_id
}

output "main_route_table_id" {
  description = "The Main Route Table ID for the VPC"
  value       = aws_vpc.this.main_route_table_id
}

output "vpc_endpoint_arn" {
  value       = [for endpoint in aws_vpc_endpoint.this : endpoint.arn]
  description = "The ARN of the VPC Endpoint Connection."
}

output "igw_id" {
  description = "Internet gateway ID for the VPC"
  value       = var.create_internet_gateway ? aws_internet_gateway.this[0].id : null
}

output "vpc_default_network_acl_id" {
  description = "The ID of the network ACL created by default on VPC creation"
  value       = aws_vpc.this.default_network_acl_id
}
