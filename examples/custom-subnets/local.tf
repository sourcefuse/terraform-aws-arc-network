locals {

  prefix = "${var.namespace}-${var.environment}"

  subnet_map = {
    "${local.prefix}-public-az1" = {
      name                    = "${local.prefix}-public-az1"
      cidr_block              = "10.0.0.0/19"
      availability_zone       = "us-east-1a"
      nat_gateway_name        = "${local.prefix}-az1-ngtw01"
      attach_nat_gateway      = false
      create_nat_gateway      = true
      attach_internet_gateway = true
    },
    "${local.prefix}-public-az2" = {
      name                    = "${local.prefix}-public-az2"
      cidr_block              = "10.0.32.0/19"
      availability_zone       = "us-east-1b"
      nat_gateway_name        = "${local.prefix}-az2-ngtw01"
      attach_nat_gateway      = false
      create_nat_gateway      = true
      attach_internet_gateway = true
    },
    "${local.prefix}-db-az1" = {
      name                    = "${local.prefix}-db-az1"
      cidr_block              = "10.0.64.0/19"
      availability_zone       = "us-east-1a"
      nat_gateway_name        = "${local.prefix}-az1-ngtw01"
      attach_nat_gateway      = true
      create_nat_gateway      = false
      attach_internet_gateway = false
    },
    "${local.prefix}-db-az2" = {
      name                    = "${local.prefix}-db-az2"
      cidr_block              = "10.0.96.0/19"
      availability_zone       = "us-east-1b"
      nat_gateway_name        = "${local.prefix}-az2-ngtw01"
      attach_nat_gateway      = true
      create_nat_gateway      = false
      attach_internet_gateway = false
    },
    "${local.prefix}-app-az1" = {
      name                    = "${local.prefix}-app-az1"
      cidr_block              = "10.0.128.0/19"
      availability_zone       = "us-east-1a"
      nat_gateway_name        = "${local.prefix}-az1-ngtw01"
      attach_nat_gateway      = true
      create_nat_gateway      = false
      attach_internet_gateway = false
    },
    "${local.prefix}-app-az2" = {
      name                    = "${local.prefix}-app-az2"
      cidr_block              = "10.0.160.0/19"
      availability_zone       = "us-east-1b"
      nat_gateway_name        = "${local.prefix}-az2-ngtw01"
      attach_nat_gateway      = true
      create_nat_gateway      = false
      attach_internet_gateway = false
    }
  }

}
