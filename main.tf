################################################################################
## defaults
################################################################################
terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0, >= 4.0.0, >= 4.9.0"
    }
  }
}

################################################################################
## vpc
################################################################################
module "vpc" {
  source = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=2.0.0"

  name      = "vpc"
  namespace = var.namespace
  stage     = var.environment

  ## networking / dns
  default_network_acl_deny_all  = var.default_network_acl_deny_all
  default_route_table_no_routes = var.default_route_table_no_routes
  internet_gateway_enabled      = var.internet_gateway_enabled
  dns_hostnames_enabled         = var.dns_hostnames_enabled
  dns_support_enabled           = var.dns_support_enabled

  ## security
  default_security_group_deny_all = var.default_security_group_deny_all

  ## ipv4 support
  ipv4_primary_cidr_block = var.vpc_ipv4_primary_cidr_block

  ## ipv6 support
  assign_generated_ipv6_cidr_block          = var.assign_generated_ipv6_cidr_block
  ipv6_egress_only_internet_gateway_enabled = var.ipv6_egress_only_internet_gateway_enabled

  tags = merge(var.tags, tomap({
    Name = "${var.namespace}-${var.environment}-vpc",
  }))
}

################################################################################
## vpn
################################################################################
resource "aws_vpn_gateway" "this" {
  count = var.vpn_gateway_enabled == true ? 1 : 0

  vpc_id = module.vpc.vpc_id

  tags   = merge(var.tags, tomap({
    Name = "${var.namespace}-${var.environment}-vpn-gw"
  }))
}

################################################################################
## vpc endpoint
################################################################################
module "vpc_endpoints" {
  source = "git::https://github.com/cloudposse/terraform-aws-vpc.git//modules/vpc-endpoints?ref=2.0.0"
  count  = var.vpc_endpoints_enabled == true ? 1 : 0

  vpc_id                  = module.vpc.vpc_id
  gateway_vpc_endpoints   = var.gateway_vpc_endpoints
  interface_vpc_endpoints = var.interface_vpc_endpoints

  tags = var.tags
}

################################################################################
## direct connect
################################################################################
resource "aws_dx_connection" "this" {
  count = var.direct_connect_enabled == true ? 1 : 0

  name            = "${var.namespace}-${var.environment}-dx-connection"
  bandwidth       = var.direct_connect_bandwidth
  provider_name   = var.direct_connect_provider
  location        = var.direct_connect_location
  request_macsec  = var.direct_connect_request_macsec
  encryption_mode = var.direct_connect_encryption_mode
  skip_destroy    = var.direct_connect_skip_destroy

  tags = merge(var.tags, tomap({
    Name = "${var.namespace}-${var.environment}-dx-connection"
  }))
}

################################################################################
## subnets
################################################################################
module "public_subnets" {
  source = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=0.15.0"

  namespace           = var.namespace
  stage               = var.environment
  type                = "public"
  vpc_id              = module.vpc.vpc_id
  availability_zones  = var.availability_zones
  cidr_block          = local.public_cidr_block
  igw_id              = module.vpc.igw_id
  nat_gateway_enabled = "true"

  tags = merge(var.tags, tomap({
    Name = "${var.namespace}-${var.environment}-public-subnet"
  }))
}

module "private_subnets" {
  source = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=0.15.0"

  namespace          = var.namespace
  stage              = var.environment
  type               = "private"
  vpc_id             = module.vpc.vpc_id
  availability_zones = var.availability_zones
  cidr_block         = local.private_cidr_block
  az_ngw_ids         = module.public_subnets.az_ngw_ids

  tags = merge(var.tags, tomap({
    Name = "${var.namespace}-${var.environment}-private-subnet"
  }))
}
