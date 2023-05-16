################################################################################
## defaults
################################################################################
terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_default_network_acl" "this" {
  default_network_acl_id = var.default_network_acl_id
  subnet_ids = concat(
    values(aws_subnet.private)[*].id,
    values(aws_subnet.public)[*].id
  )

  ingress {
    action     = "allow"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
    protocol   = "-1"
    rule_no    = 100
  }

  egress {
    action     = "allow"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
    protocol   = "-1"
    rule_no    = 100
  }

  tags = var.tags
}

################################################################################
## private
################################################################################
## subnet
resource "aws_subnet" "private" {
  for_each = { for x in var.private_subnets : x.name => x }

  vpc_id            = var.vpc_id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.cidr_block

  tags = merge(var.tags, each.value.tags, tomap({
    Name = each.value.name
  }))
}

## network acl
resource "aws_network_acl" "private" {
  count      = var.create_aws_network_acl == true ? 1 : 0

  vpc_id     = var.vpc_id
  subnet_ids = var.private_network_acl_subnet_ids

  dynamic "ingress" {
    for_each = var.private_network_acl_ingress

    content {
      rule_no         = ingress.value.rule_no
      action          = ingress.value.action
      cidr_block      = ingress.value.cidr_block
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      icmp_code       = ingress.value.icmp_code
      icmp_type       = ingress.value.icmp_type
      ipv6_cidr_block = ingress.value.ipv6_cidr_block
    }
  }

  dynamic "egress" {
    for_each = var.private_network_acl_egress

    content {
      rule_no         = egress.value.rule_no
      action          = egress.value.action
      cidr_block      = egress.value.cidr_block
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      icmp_code       = egress.value.icmp_code
      icmp_type       = egress.value.icmp_type
      ipv6_cidr_block = egress.value.ipv6_cidr_block
    }
  }

  tags       = var.tags
  depends_on = [aws_subnet.private]
}

## route table
resource "aws_route_table" "private" {
  for_each = { for x in var.private_subnets : x.name => x }

  vpc_id = var.vpc_id

  tags = merge(var.tags, var.private_route_table_additional_tags, tomap({
    Name = each.value.name
    }),
  )
}

resource "aws_route" "default" {
  for_each = var.az_ngw_ids

  route_table_id         = aws_route_table.private[each.key].id
  nat_gateway_id         = each.value
  destination_cidr_block = "0.0.0.0/0"

  depends_on = [aws_route_table.private]
}

resource "aws_route_table_association" "private" {
  for_each = { for x in var.private_subnets : x.name => x }

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id

  depends_on = [
    aws_subnet.private,
    aws_route_table.private,
  ]
}

################################################################################
## public
################################################################################
## subnet
resource "aws_subnet" "public" {
  for_each = { for x in var.public_subnets : x.name => x }

  vpc_id                  = var.vpc_id
  availability_zone       = each.value.availability_zone
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = merge(var.tags, each.value.tags, tomap({
    Name = each.value.name
  }))
}

resource "aws_route_table" "public" {
  for_each = { for x in var.public_subnets : x.name => x }

  vpc_id = var.vpc_id

  tags = merge(var.tags, var.public_route_table_additional_tags, tomap({
    Name = each.value.name
  }))
}

resource "aws_route" "public" {
  for_each = { for x in var.public_subnets : x.name => x }

  route_table_id         = aws_route_table.public[each.key].id
  gateway_id             = var.igw_id // TODO - update this
  destination_cidr_block = "0.0.0.0/0"

  depends_on = [aws_route_table.public]
}

resource "aws_route_table_association" "public" {
  for_each = { for x in var.public_subnets : x.name => x if var.route_table_association_enabled == true }

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[each.key].id

  depends_on = [
    aws_subnet.public,
    aws_route_table.public,
  ]
}

## elastic public ip
resource "aws_eip" "public" {
  for_each = { for x in var.public_subnets : x.name => x if var.nat_gateway_enabled == true }

  vpc = true

  tags = merge(var.tags, tomap({
    Name = each.value.name
  }))

  lifecycle {
    create_before_destroy = true
  }
}

## nat gateway
resource "aws_nat_gateway" "public" {
  for_each = { for x in var.public_subnets : x.name => x if var.nat_gateway_enabled == true }

  allocation_id = aws_eip.public[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(var.tags, tomap({
    Name = each.value.name
  }))

  depends_on = [aws_subnet.public]

  lifecycle {
    create_before_destroy = true
  }
}
