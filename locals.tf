locals {
  public_cidr_block         = cidrsubnet(module.vpc.vpc_cidr_block, 1, 0)
  private_cidr_block        = cidrsubnet(module.vpc.vpc_cidr_block, 1, 1)
  organization_name         = var.client_vpn_organization_name == "" ? "${var.environment}.${var.namespace}" : var.client_vpn_organization_name
  vpn_subnets               = [for az, subnets in module.private_subnets.az_subnet_ids : subnets]
  vpn_endpoint_arn          = try(module.client_vpn[*].vpn_endpoint_arn, [])
  vpn_endpoint_dns_name     = try(module.client_vpn[*].vpn_endpoint_dns_name, [])
  full_client_configuration = try(module.client_vpn[*].full_client_configuration, [])

  ##############################################################################
  ## resource naming
  ##############################################################################
  default_base_name = "${var.namespace}-${var.environment}"

  ## vpc
  vpc_name = var.vpc_name_override != null ? var.vpc_name_override : "${local.default_base_name}-vpc"

  ## client vpn
  client_vpn_name = var.client_vpn_name_override != null ? var.client_vpn_name_override : "${local.default_base_name}-client-vpn"
}
