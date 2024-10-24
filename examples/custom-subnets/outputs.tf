output "vpc_id" {
  value       = module.network.id
  description = "VPC ID"
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.network.private_subnet_ids
}

# output "public_subnet_cidrs" {
#   value = module.network.public_subnet_cidrs
# }

# output "private_subnet_cidrs" {
#   value = module.network.private_subnet_cidrs
# }
