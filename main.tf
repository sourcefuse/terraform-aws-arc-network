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

    awsutils = {
      source  = "cloudposse/awsutils"
      version = "~> 0.15"
    }
  }
}

################################################################################
## vpc
################################################################################
module "vpc" {
  source = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=2.0.0"

  name = local.vpc_name

  ## networking / dns
  default_network_acl_deny_all  = var.default_network_acl_deny_all
  default_route_table_no_routes = var.default_route_table_no_routes
  internet_gateway_enabled      = var.internet_gateway_enabled
  dns_hostnames_enabled         = var.dns_hostnames_enabled
  dns_support_enabled           = var.dns_support_enabled

  ## security
  default_security_group_deny_all = var.default_security_group_deny_all

  ## ipv4 support
  ipv4_primary_cidr_block = var.vpc_ipv4_primary_cidr_block

  ## ipv6 support
  assign_generated_ipv6_cidr_block          = var.assign_generated_ipv6_cidr_block
  ipv6_egress_only_internet_gateway_enabled = var.ipv6_egress_only_internet_gateway_enabled

  tags = merge(var.tags, tomap({
    Name = local.vpc_name,
  }))
}

################################################################################
## vpn
################################################################################
## site to site VPN (meant for connect with other networks via BGP)
resource "aws_vpn_gateway" "this" {
  count = var.vpn_gateway_enabled == true ? 1 : 0

  vpc_id = module.vpc.vpc_id

  tags = merge(var.tags, tomap({
    Name = local.client_vpn_name
  }))
}

## client VPN
## meant to provide connectivity to AWS VPCs to authorised users from
## their end systems / workstations)
module "client_vpn" {
  count  = var.client_vpn_enabled == true ? 1 : 0
  source = "git::https://github.com/cloudposse/terraform-aws-ec2-client-vpn?ref=0.14.0"

  name                = local.client_vpn_name
  vpc_id              = module.vpc.vpc_id
  client_cidr         = var.client_vpn_client_cidr_block
  organization_name   = local.organization_name
  logging_enabled     = var.client_vpn_logging_enabled
  logging_stream_name = "${local.client_vpn_name}-logs"
  retention_in_days   = var.client_vpn_retention_in_days
  associated_subnets  = local.vpn_subnets
  split_tunnel        = var.client_vpn_split_tunnel
  authorization_rules = var.client_vpn_authorization_rules

  create_security_group         = var.client_vpn_create_security_group
  allowed_security_group_ids    = var.client_vpn_allowed_security_group_ids
  associated_security_group_ids = var.client_vpn_associated_security_group_ids

  tags = merge(var.tags, tomap({
    Name = local.client_vpn_name
  }))
}

################################################################################
## vpc endpoint
################################################################################
module "vpc_endpoints" {
  source = "git::https://github.com/cloudposse/terraform-aws-vpc.git//modules/vpc-endpoints?ref=2.0.0"
  count  = var.vpc_endpoints_enabled == true ? 1 : 0

  vpc_id                  = module.vpc.vpc_id
  gateway_vpc_endpoints   = var.gateway_vpc_endpoints
  interface_vpc_endpoints = var.interface_vpc_endpoints

  tags = var.tags
}

# Create a default VPC endpoint for S3
resource "aws_vpc_endpoint" "s3_endpoint" {
  count               = var.vpc_endpoint_config.s3 == true ? 1 : 0
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type   = "Gateway"
  route_table_ids     = module.vpc.vpc_default_route_table_id
  private_dns_enabled = var.private_dns_enabled
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowS3Access"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      }
    ]
  })

  tags = merge(var.tags, tomap({
    Name = local.s3_endpoint_name
  }))
}

# Create a default VPC endpoint for DynamoDB
resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  # Create a default VPC endpoint for DynamoDB only if the `create_dynamodb_endpoint` variable is set to true
  count = var.vpc_endpoint_config.dynamodb == true ? 1 : 0
  # Specify the VPC ID where the endpoint will be created
  vpc_id = module.vpc.vpc_id

  # Specify the service name and endpoint type
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  # Specify the route table IDs to associate with the endpoint
  route_table_ids = module.vpc.vpc_default_route_table_id

  policy = data.aws_iam_policy_document.dynamodb.json

  # Specify whether or not to enable private DNS
  private_dns_enabled = var.private_dns_enabled

  tags = merge(var.tags, tomap({
    Name = local.dynamodb_endpoint_name
  }))
}

data "aws_iam_policy_document" "dynamodb" {
  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = ["arn:aws:dynamodb:${var.aws_region}:table/*"]
  }
}

# Create a default VPC endpoint for EC2
resource "aws_vpc_endpoint" "ec2_endpoint" {
  count = var.vpc_endpoint_config.ec2 == true ? 1 : 0

  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${var.aws_region}.ec2"
  security_group_ids = module.vpc.vpc_default_security_group_id

  vpc_endpoint_type   = var.vpc_endpoint_type // Gateway type endpoints are available only for AWS services including S3 and DynamoDB
  private_dns_enabled = var.private_dns_enabled
  policy              = data.aws_iam_policy_document.ec2.json

  tags = merge(var.tags, tomap({
    Name = local.ec2_endpoint_name
  }))
}

data "aws_iam_policy_document" "ec2" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeImages",
      "ec2:DescribeTags",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeKeyPairs",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeRouteTables",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyVpcEndpoint",
      "ec2:AttachNetworkInterface",
      "ec2:DetachNetworkInterface",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses",
    ]
    resources = ["*"]
  }
}

# Create a default VPC endpoint for KMS
resource "aws_vpc_endpoint" "kms_endpoint" {
  count               = var.vpc_endpoint_config.kms == true ? 1 : 0
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.kms"
  vpc_endpoint_type   = var.vpc_endpoint_type // Gateway type endpoints are available only for AWS services including S3 and DynamoDB
  private_dns_enabled = var.private_dns_enabled
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = ["*"]
      }
    ]
  })

  tags = merge(var.tags, tomap({
    Name = local.kms_endpoint_name
  }))
}

# Create a default VPC endpoint for ELB
resource "aws_vpc_endpoint" "elb_endpoint" {
  count = var.vpc_endpoint_config.elb == true ? 1 : 0

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.elasticloadbalancing"
  vpc_endpoint_type   = var.vpc_endpoint_type // Gateway type endpoints are available only for AWS services including S3 and DynamoDB
  auto_accept         = true
  private_dns_enabled = var.private_dns_enabled
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "elasticloadbalancing:*"
        ]
        Effect    = "Allow"
        Resource  = "*"
        Principal = "*"
      }
    ]
  })

  tags = merge(var.tags, tomap({
    Name = local.elb_endpoint_name
  }))
}

# Create a default VPC endpoint for Cloudwatch
resource "aws_vpc_endpoint" "cloudwatch_endpoint" {
  count = var.vpc_endpoint_config.cloudwatch == true ? 1 : 0

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = var.vpc_endpoint_type // Gateway type endpoints are available only for AWS services including S3 and DynamoDB
  private_dns_enabled = var.private_dns_enabled
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Resource = "*",
      },
    ],
  })

  tags = merge(var.tags, tomap({
    Name = local.cloudwatch_endpoint_name
  }))
}

################################################################################
## direct connect
################################################################################
resource "aws_dx_connection" "this" {
  count = var.direct_connect_enabled == true ? 1 : 0

  name            = local.aws_dx_connection_name
  bandwidth       = var.direct_connect_bandwidth
  provider_name   = var.direct_connect_provider
  location        = var.direct_connect_location
  request_macsec  = var.direct_connect_request_macsec
  encryption_mode = var.direct_connect_encryption_mode
  skip_destroy    = var.direct_connect_skip_destroy

  tags = merge(var.tags, tomap({
    Name = local.aws_dx_connection_name
  }))
}

################################################################################
## subnets
################################################################################
module "custom_subnets" {
  source = "./modules/subnets"
  count  = var.custom_subnets_enabled == true ? 1 : 0

  create_aws_network_acl = false
  default_network_acl_id = module.vpc.vpc_default_network_acl_id
  vpc_id                 = module.vpc.vpc_id
  private_subnets        = var.custom_private_subnets
  public_subnets         = var.custom_public_subnets

  tags = var.tags
}

module "public_subnets" {
  source = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=0.15.0"

  enabled             = var.custom_subnets_enabled == true ? false : var.auto_generate_multi_az_subnets
  name                = local.public_subnet_name
  type                = "public"
  vpc_id              = module.vpc.vpc_id
  availability_zones  = var.availability_zones
  cidr_block          = local.public_cidr_block
  igw_id              = module.vpc.igw_id
  nat_gateway_enabled = "true"

  tags = merge(var.tags, tomap({
    Name = local.public_subnet_name
  }))
}

module "private_subnets" {
  source = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=0.15.0"

  enabled            = var.custom_subnets_enabled == true ? false : var.auto_generate_multi_az_subnets
  name               = local.private_subnet_name
  type               = "private"
  vpc_id             = module.vpc.vpc_id
  availability_zones = var.availability_zones
  cidr_block         = local.private_cidr_block
  az_ngw_ids         = module.public_subnets.az_ngw_ids

  tags = merge(var.tags, tomap({
    Name = local.private_subnet_name
  }))
}
