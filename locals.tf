locals {
  public_cidr_block         = cidrsubnet(module.vpc.vpc_cidr_block, 1, 0)
  private_cidr_block        = cidrsubnet(module.vpc.vpc_cidr_block, 1, 1)
  organization_name         = var.client_vpn_organization_name == "" ? "${var.environment}.${var.namespace}" : var.client_vpn_organization_name
  vpn_subnets               = [for az, subnets in module.private_subnets.az_subnet_ids : subnets]
  vpn_endpoint_arn          = try(module.client_vpn[*].vpn_endpoint_arn, [])
  vpn_endpoint_dns_name     = try(module.client_vpn[*].vpn_endpoint_dns_name, [])
  full_client_configuration = try(module.client_vpn[*].full_client_configuration, [])

  ##############################################################################
  ## resource naming
  ##############################################################################
  default_base_name = "${var.namespace}-${var.environment}"

  ## vpc
  vpc_name = var.vpc_name_override != null ? var.vpc_name_override : "${local.default_base_name}-vpc"

  ## aws dx connection
  aws_dx_connection_name = var.aws_dx_connection_name_override != null ? var.aws_dx_connection_name_override : "${local.default_base_name}-dx-connection"

  ## cloudwatch endpoint
  cloudwatch_endpoint_name = var.cloudwatch_endpoint_name_override != null ? var.cloudwatch_endpoint_name_override : "${local.default_base_name}-cloudwatch-endpoint"

  ## client vpn
  client_vpn_name = var.client_vpn_name_override != null ? var.client_vpn_name_override : "${local.default_base_name}-client-vpn"

  ## elb endpoint
  elb_endpoint_name = var.elb_endpoint_name_override != null ? var.elb_endpoint_name_override : "${local.default_base_name}-elb-endpoint"

  ## public subnets
  public_subnet_name = var.public_subnet_name_override != null ? var.public_subnet_name_override : "${local.default_base_name}-public-subnet"

  ## private subnets
  private_subnet_name = var.private_subnet_name_override != null ? var.private_subnet_name_override : "${local.default_base_name}-private-subnet"

  ## kms endpoint
  kms_endpoint_name = var.kms_endpoint_name_override != null ? var.kms_endpoint_name_override : "${local.default_base_name}-kms-endpoint"

  ## ec2 endpoint
  ec2_endpoint_name = var.ec2_endpoint_name_override != null ? var.ec2_endpoint_name_override : "${local.default_base_name}-ec2-endpoint"

  ## dynamodb endpoint
  dynamodb_endpoint_name = var.dynamodb_endpoint_name_override != null ? var.dynamodb_endpoint_name_override : "${local.default_base_name}-dynamodb-endpoint"

  ## s3 endpoint
  s3_endpoint_name = var.s3_endpoint_name_override != null ? var.s3_endpoint_name_override : "${local.default_base_name}-s3-endpoint"

  ## sns endpoint
  sns_endpoint_name = var.sns_endpoint_name_override != null ? var.sns_endpoint_name_override : "${local.default_base_name}-sns-endpoint"

  ## sqs endpoint
  sqs_endpoint_name = var.sqs_endpoint_name_override != null ? var.sqs_endpoint_name_override : "${local.default_base_name}-sqs-endpoint"

  ## ecs endpoint
  ecs_endpoint_name = var.ecs_endpoint_name_override != null ? var.ecs_endpoint_name_override : "${local.default_base_name}-ecs-endpoint"

  ## rds endpoint
  rds_endpoint_name = var.rds_endpoint_name_override != null ? var.rds_endpoint_name_override : "${local.default_base_name}-rds-endpoint"


  ## Outputs handlers
  public_subnet_ids  = module.public_subnets.az_subnet_ids != {} ? module.public_subnets.az_subnet_ids : module.custom_subnets[0].public_subnet_ids
  private_subnet_ids = module.private_subnets.az_subnet_ids != {} ? module.private_subnets.az_subnet_ids : module.custom_subnets[0].private_subnet_ids
}
