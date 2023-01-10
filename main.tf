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
  default_network_acl_deny_all  = false # TODO - make into variable
  default_route_table_no_routes = false # TODO - make into variable
  internet_gateway_enabled      = true  # TODO - make into variable
  dns_hostnames_enabled         = true  # TODO - make into variable
  dns_support_enabled           = true  # TODO - make into variable

  ## security
  default_security_group_deny_all = true # TODO - make into variable

  ## ipv4 support
  ipv4_primary_cidr_block = var.vpc_ipv4_primary_cidr_block

  ## ipv6 support
  assign_generated_ipv6_cidr_block          = true  # TODO - make into variable
  ipv6_egress_only_internet_gateway_enabled = false # TODO - make into variable

  tags = merge(var.tags, tomap({
    Name = "${var.namespace}-${var.environment}-vpc",
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
