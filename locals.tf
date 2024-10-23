locals {

  prefix                = "${var.namespace}-${var.environment}"
  internet_gateway_name = var.internet_geteway_name != null ? "${var.namespace}-${var.environment}-igw" : var.internet_geteway_name

  nat_gateway_data = { for key, value in var.subnet_map : key => merge(value, { key = key })
  if value.create_nat_gateway }

  nat_gw_routes      = { for key, value in var.subnet_map : key => value if value.attach_nat_gateway }
  internet_gw_routes = { for key, value in var.subnet_map : key => value if value.attach_internet_gateway }

  additional_routes     = flatten([for key, value in var.subnet_map : [for route in value.additional_routes : merge({ key : key }, route)] if length(value.additional_routes) > 0])
  additional_routes_map = { for route in local.additional_routes : route.id => route }
}
