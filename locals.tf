data "aws_region" "current" {}
locals {

  prefix                = "${var.namespace}-${var.environment}"
  internet_gateway_name = var.internet_geteway_name != null ? "${var.namespace}-${var.environment}-igw" : var.internet_geteway_name

  nat_gateway_data = { for key, value in local.subnet_map : key => merge(value, { key = key })
  if value.create_nat_gateway }

  nat_gw_routes      = { for key, value in local.subnet_map : key => value if value.attach_nat_gateway }
  internet_gw_routes = { for key, value in local.subnet_map : key => value if value.attach_internet_gateway }

  additional_routes     = flatten([for key, value in local.subnet_map : [for route in value.additional_routes : merge({ key : key }, route)] if length(value.additional_routes) > 0])
  additional_routes_map = { for route in local.additional_routes : route.id => route }

  subnet_map          = var.subnet_map == null ? tomap(local.subnet_map_auto) : var.subnet_map
  enable_vpc_flow_log = var.vpc_flow_log_config.enable

  ##### KMS policy for
  kms_policy = jsonencode({
    Version = "2012-10-17"
    Id      = "VPCFlowLogsPolicy"
    Statement = [
      {
        Sid    = "AllowRootAccount"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

}
