locals {

  prefix = "${var.namespace}-${var.environment}"

  subnet_map = {
    "${local.prefix}-public" = {
      name                    = "${local.prefix}-public"
      cidr_block              = "10.0.0.0/18"
      availability_zone       = "us-east-1a"
      nat_gateway_name        = "${local.prefix}-ngtw01"
      attach_nat_gateway      = false
      create_nat_gateway      = true
      attach_internet_gateway = true
      map_public_ip_on_launch = true
    },
    "${local.prefix}-private" = {
      name                    = "${local.prefix}-private"
      cidr_block              = "10.0.64.0/18"
      availability_zone       = "us-east-1a"
      nat_gateway_name        = "${local.prefix}-ngtw01"
      attach_nat_gateway      = true
      create_nat_gateway      = false
      attach_internet_gateway = false
      map_public_ip_on_launch = false
    }
  }

}
