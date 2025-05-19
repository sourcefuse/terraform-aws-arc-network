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
      Name = "${var.name}-vpc"
    },
    var.tags
  )
}

resource "aws_internet_gateway" "this" {
  count  = var.create_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = local.internet_gateway_name
    },
    var.tags
  )
}

resource "aws_subnet" "this" {

  for_each = local.subnet_map

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
      Name = each.value.nat_gateway_name
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}

# Creates one Route table for each Subnet
resource "aws_route_table" "this" {
  for_each = local.subnet_map

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
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "this" {
  for_each = local.subnet_map

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

# Module for KMS Key Management
module "kms" {
  source                  = "sourcefuse/arc-kms/aws"
  version                 = "1.0.9"
  count                   = var.vpc_flow_log_config.enable ? 1 : 0
  deletion_window_in_days = var.kms_config.deletion_window_in_days
  enable_key_rotation     = var.kms_config.enable_key_rotation
  alias                   = "alias/${var.name}-vpc-flow-logs-key"
  tags = merge(
    {
      Name = "${var.name}-kms-vpc-flowlogs"
    },
    var.tags
  )
  policy = local.kms_policy
}

#### AWS Caller Identity Data Source
data "aws_caller_identity" "current" {}

### CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "this" {
  count             = var.vpc_flow_log_config.enable ? 1 : 0
  name_prefix       = "${var.name}-vpcflowlog"
  kms_key_id        = module.kms[0].key_arn
  retention_in_days = var.vpc_flow_log_config.retention_in_days
}

### IAM Policy Document for VPC Flow Logs Role Trust Policy
data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

### IAM Role for VPC Flow Logs
resource "aws_iam_role" "this" {
  count              = var.vpc_flow_log_config.enable ? 1 : 0
  name_prefix        = "${var.name}-vpcflowlog-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

# IAM Policy for Flow Logs
data "aws_iam_policy_document" "flow_logs_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = local.enable_vpc_flow_log && length(aws_cloudwatch_log_group.this) > 0 ? [aws_cloudwatch_log_group.this[0].arn, "${aws_cloudwatch_log_group.this[0].arn}:*"] : ["*"]

  }
}

resource "aws_iam_policy" "this" {
  count       = var.vpc_flow_log_config.enable ? 1 : 0
  name_prefix = "${var.name}-vpcflowlog-policy"
  policy      = data.aws_iam_policy_document.flow_logs_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_flow_logs_policy" {
  count      = var.vpc_flow_log_config.enable ? 1 : 0
  role       = aws_iam_role.this[count.index].name
  policy_arn = aws_iam_policy.this[count.index].arn
}


# VPC Flow Log Configuration

resource "aws_flow_log" "this" {
  count        = var.vpc_flow_log_config.enable ? 1 : 0
  traffic_type = "ALL"
  vpc_id       = aws_vpc.this.id


  log_destination_type = var.vpc_flow_log_config.s3_bucket_arn != null && var.vpc_flow_log_config.s3_bucket_arn != "" ? "s3" : "cloud-watch-logs"
  log_destination      = var.vpc_flow_log_config.s3_bucket_arn != null && var.vpc_flow_log_config.s3_bucket_arn != "" ? var.vpc_flow_log_config.s3_bucket_arn : aws_cloudwatch_log_group.this[0].arn
  iam_role_arn         = var.vpc_flow_log_config.s3_bucket_arn == null || var.vpc_flow_log_config.s3_bucket_arn == "" ? aws_iam_role.this[0].arn : null

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-flowlogs"
    }
  )

}
