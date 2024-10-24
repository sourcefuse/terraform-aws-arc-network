data "aws_region" "this" {}

data "aws_route_tables" "private" {
  count  = length(var.vpc_endpoint_data) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }

  depends_on = [aws_route_table.this]
}

data "aws_route_tables" "public" {
  count  = length(var.vpc_endpoint_data) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }

  depends_on = [aws_route_table.this]
}

resource "aws_vpc_endpoint" "this" {
  for_each = { for obj in var.vpc_endpoint_data : obj.service => obj }

  vpc_id             = aws_vpc.this.id
  service_name       = "com.amazonaws.${data.aws_region.this.name}.${each.key}"
  vpc_endpoint_type  = each.key == "s3" || each.key == "dynamodb" ? "Gateway" : "Interface"
  route_table_ids    = each.value.route_table_filter == "private" ? data.aws_route_tables.private[0].ids : concat(data.aws_route_tables.private[0].ids, data.aws_route_tables.public[0].ids)
  policy             = each.value.policy_doc == null ? local.endpoint_policies[each.key] : each.value.policy_doc
  security_group_ids = each.key == "s3" || each.key == "dynamodb" ? [] : each.value.security_group_ids
  auto_accept        = true

  tags = merge(var.tags, {
    Name = "${local.prefix}-${each.key}-endpoint"
  })
}
