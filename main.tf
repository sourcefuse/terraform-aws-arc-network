################################################################################
## defaults
################################################################################
terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.44"
    }
  }
}

################################################################################
## vpc
################################################################################
module "vpc" {
  source = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=2.0.0"

  name                    = "vpc"
  namespace               = var.namespace
  stage                   = var.environment
  ipv4_primary_cidr_block = var.ipv4_primary_cidr_block

  tags = var.tags
}

################################################################################
## subnets
################################################################################
## public
module "public_subnets" {
  source = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=0.15.0"

  namespace           = var.namespace
  stage               = var.environment
  vpc_id              = module.vpc.vpc_id
  cidr_block          = local.public_cidr_block
  availability_zones  = var.availability_zones
  type                = "public"
  igw_id              = module.vpc.igw_id
  nat_gateway_enabled = "true"

  tags = var.tags
}

## private
module "private_subnets" {
  source = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=0.15.0"

  namespace          = var.namespace
  stage              = var.environment
  vpc_id             = module.vpc.vpc_id
  cidr_block         = local.private_cidr_block
  availability_zones = var.availability_zones
  type               = "private"
  az_ngw_ids         = module.public_subnets.az_ngw_ids

  tags = var.tags
}

################################################################################
## security
################################################################################
resource "aws_security_group" "standard_web_sg" {
  name   = "${var.namespace}-${var.environment}-standard-web-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = var.default_ingress
  }

  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = var.default_ingress
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.default_egress
  }

  tags = merge(var.tags, tomap({
    Name = "${var.namespace}-${var.environment}-standard-web-sg"
  }))
}
