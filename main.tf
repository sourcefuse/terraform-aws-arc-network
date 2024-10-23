resource "aws_vpc" "this" {
  cidr_block                           = var.cidr_block
  instance_tenancy                     = var.instance_tenancy
  enable_dns_support                   = var.enable_dns_support
  enable_dns_hostnames                 = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block     = var.assign_generated_ipv6_cidr_block
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics

  ipv6_cidr_block                      = var.ipv6_cidr_block
  ipv6_ipam_pool_id                    = var.ipv6_ipam_pool_id
  ipv6_netmask_length                  = var.ipv6_netmask_length
  ipv6_cidr_block_network_border_group = var.ipv6_cidr_block_network_border_group

  ipv4_ipam_pool_id   = var.ipv4_ipam_pool_id
  ipv4_netmask_length = var.ipv4_netmask_length

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = local.internet_gateway_name
    },
    var.tags
  )
}

resource "aws_subnet" "this" {

  for_each = var.subnet_map

  vpc_id                                         = aws_vpc.this.id
  cidr_block                                     = each.value.cidr_block
  availability_zone                              = each.value.availability_zone
  enable_resource_name_dns_a_record_on_launch    = each.value.enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = each.value.enable_resource_name_dns_aaaa_record_on_launch
  map_public_ip_on_launch                        = each.value.map_public_ip_on_launch

  ipv6_native                     = each.value.ipv6_native
  assign_ipv6_address_on_creation = each.value.assign_ipv6_address_on_creation
  ipv6_cidr_block                 = each.value.ipv6_cidr_block
  enable_dns64                    = each.value.enable_dns64


  tags = merge(
    {
      Name = each.value.name
    },
    var.tags
  )
}

resource "aws_eip" "nat_gw" {
  for_each = local.nat_gateway_data

  tags = merge(
    {
      Name = "${each.key}-eip"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  for_each = { for key, value in local.nat_gateway_data : value.nat_gateway_name => value } // This is to change the keys

  allocation_id = aws_eip.nat_gw[each.value.key].id
  subnet_id     = aws_subnet.this[each.value.key].id

  tags = merge(
    {
      Name = "${each.value.availability_zone}-ngw"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}

# Creates one Route table for each Subnet
resource "aws_route_table" "this" {
  for_each = var.subnet_map

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = each.value.attach_internet_gateway ? "${each.value.name}-public-route" : "${each.value.name}-private-route"
    },
    var.tags
  )
}

resource "aws_route" "nat" {
  for_each = local.nat_gw_routes

  route_table_id         = aws_route_table.this[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.value.nat_gateway_name].id
}

resource "aws_route" "internet_gw" {
  for_each = local.internet_gw_routes

  route_table_id         = aws_route_table.this[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "this" {
  for_each = var.subnet_map

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this[each.key].id
}

resource "aws_route" "additional" {
  for_each = local.additional_routes_map

  route_table_id              = aws_route_table.this[each.value.key].id
  destination_cidr_block      = each.value.destination_cidr_block
  destination_ipv6_cidr_block = each.value.destination_ipv6_cidr_block

  egress_only_gateway_id    = each.value.type == "egress-only-gateway" ? each.value.id : null
  network_interface_id      = each.value.type == "network-interface" ? each.value.id : null
  transit_gateway_id        = each.value.type == "transit-gateway" ? each.value.id : null
  vpc_endpoint_id           = each.value.type == "vpc-endpoint" ? each.value.id : null
  vpc_peering_connection_id = each.value.type == "vpc-peering-connection" ? each.value.id : null
}

resource "aws_route_table_association" "additional" {
  for_each = local.additional_routes_map

  subnet_id      = aws_subnet.this[each.value.key].id
  route_table_id = aws_route_table.this[each.value.key].id
}
