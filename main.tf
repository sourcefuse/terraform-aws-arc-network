module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=0.27.0"
  namespace  = var.namespace
  name       = "vpc"
  stage      = var.environment
  cidr_block = var.vpc_cidr_block
  tags = merge(var.tags, tomap({
    Name         = "${var.namespace}-${var.environment}-vpc",
    LastModified = local.datetime
  }))
}

locals {
  public_cidr_block  = cidrsubnet(module.vpc.vpc_cidr_block, 1, 0)
  private_cidr_block = cidrsubnet(module.vpc.vpc_cidr_block, 1, 1)
}

module "public_subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=0.14.1"
  namespace           = var.namespace
  stage               = var.environment
  name                = "publicsubnet"
  availability_zones  = var.availability_zones
  vpc_id              = module.vpc.vpc_id
  cidr_block          = local.public_cidr_block
  type                = "public"
  igw_id              = module.vpc.igw_id
  nat_gateway_enabled = "true"
  tags = merge(var.tags, {
    "Name" = "${var.namespace}-${var.environment}-public-subnet"
  })
}

module "private_subnets" {
  source             = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=0.14.1"
  namespace          = var.namespace
  stage              = var.environment
  name               = "privatesubnet"
  availability_zones = var.availability_zones
  vpc_id             = module.vpc.vpc_id
  cidr_block         = local.private_cidr_block
  type               = "private"
  tags = merge(var.tags, tomap({
    "Name" = "${var.namespace}-${var.environment}-db-private-subnet"
  }))
  az_ngw_ids = module.public_subnets.az_ngw_ids
}


module "aws_key_pair" {
  source              = "cloudposse/key-pair/aws"
  version             = "0.18.2"
  attributes          = ["ssh", "key"]
  ssh_public_key_path = var.ssh_key_path
  generate_ssh_key    = var.generate_ssh_key

  context = module.this.context
}


module "ec2_bastion" {
  source = "git::https://github.com/cloudposse/terraform-aws-ec2-bastion-server.git?ref=0.27.0"

  enabled = module.this.enabled

  instance_type               = var.instance_type
  security_groups             = compact(concat([module.vpc.vpc_default_security_group_id], var.security_groups))
  subnets                     = [for sub_id in module.public_subnets.az_subnet_ids : sub_id]
  key_name                    = module.aws_key_pair.key_name
  user_data                   = var.user_data
  vpc_id                      = module.vpc.vpc_id
  associate_public_ip_address = var.associate_public_ip_address

  context = module.this.context
}
