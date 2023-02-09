locals {
  public_cidr_block  = cidrsubnet(module.vpc.vpc_cidr_block, 1, 0)
  private_cidr_block = cidrsubnet(module.vpc.vpc_cidr_block, 1, 1)
  organization_name  = var.client_vpn_organization_name == "" ? "${var.environment}.${var.namespace}" : var.client_vpn_organization_name

  ## vpn
  vpn_subnets           = [for az, subnets in module.private_subnets.az_subnet_ids : subnets]
  vpn_endpoint_arn      = var.client_vpn_enabled ? module.client_vpn[0].vpn_endpoint_arn : null      ## TODO - remove [0] on final commit
  vpn_endpoint_dns_name = var.client_vpn_enabled ? module.client_vpn[0].vpn_endpoint_dns_name : null ## TODO - remove [0] on final commit
}
