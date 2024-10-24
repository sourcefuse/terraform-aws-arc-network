locals {

  # Subnet map is automatically derived if var.subnet_map is null

  private_cidr = cidrsubnet(var.cidr_block, 1, 0)
  public_cidr  = cidrsubnet(var.cidr_block, 1, 1)

  subnet_bits = ceil(log(length(var.availability_zones), 2))

  public_subnet_data = { for idx, az in var.availability_zones : "${var.name}-public-${az}-${idx + 1}" => {
    name                    = "${var.name}-${az}-${idx + 1}"
    cidr_block              = cidrsubnet(local.public_cidr, local.subnet_bits, idx)
    availability_zone       = az
    nat_gateway_name        = null
    create_nat_gateway      = false
    attach_nat_gateway      = false
    attach_internet_gateway = true

    enable_resource_name_dns_a_record_on_launch    = false
    enable_resource_name_dns_aaaa_record_on_launch = false
    map_public_ip_on_launch                        = false
    ipv6_native                                    = false
    assign_ipv6_address_on_creation                = false
    ipv6_cidr_block                                = null
    enable_dns64                                   = false
    additional_routes                              = []
    }
  }
  private_subnet_data = { for idx, az in var.availability_zones : "${var.name}-private-${az}-${idx + 1}" => {
    name                    = "${var.name}-${az}-${idx + 1}"
    cidr_block              = cidrsubnet(local.private_cidr, local.subnet_bits, idx)
    availability_zone       = az
    nat_gateway_name        = "${var.name}-${az}-ngw-${idx + 1}"
    create_nat_gateway      = true
    attach_nat_gateway      = true
    attach_internet_gateway = false

    enable_resource_name_dns_a_record_on_launch    = false
    enable_resource_name_dns_aaaa_record_on_launch = false
    map_public_ip_on_launch                        = false
    ipv6_native                                    = false
    assign_ipv6_address_on_creation                = false
    ipv6_cidr_block                                = null
    enable_dns64                                   = false
    additional_routes                              = []
    }
  }

  subnet_map_auto = merge(local.public_subnet_data, local.private_subnet_data)
}
