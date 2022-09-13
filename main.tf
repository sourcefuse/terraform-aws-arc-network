terraform {
  required_version = ">= 1.0.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

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

## security
resource "aws_security_group" "standard_web_sg" {
  name   = "${var.namespace}-${var.environment}-alb-standard-web-sg"
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
    Name = "${var.namespace}-${var.environment}-alb-standard-web-sg"
  }))
}

// TODO: lock down SGs below to limit traffic to the VPC
resource "aws_security_group" "ecs_tasks_sg" {
  name   = "${var.namespace}-${var.environment}-ecs-tasks-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 0
    protocol  = "tcp"
    to_port   = 65535

    cidr_blocks = var.default_ingress
  }

  egress {
    from_port   = 0
    protocol    = "tcp"
    to_port     = 65535
    cidr_blocks = var.default_egress
  }

  tags = merge(var.tags, tomap({
    Name = "${var.namespace}-${var.environment}-ecs-tasks-sg"
  }))
}

resource "aws_security_group" "eks_sg" {
  name   = "${var.namespace}-${var.environment}-eks-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 0
    protocol  = "tcp"
    to_port   = 65535

    cidr_blocks = var.default_ingress
  }

  egress {
    from_port   = 0
    protocol    = "tcp"
    to_port     = 65535
    cidr_blocks = var.default_egress
  }

  tags = merge(var.tags, tomap({
    Name = "${var.namespace}-${var.environment}-ecs-tasks-sg"
  }))
}

resource "aws_security_group" "db_sg" {
  name   = "${var.namespace}-${var.environment}-db-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Ingress from VPC"
    to_port     = 5432
    from_port   = 5432
    protocol    = "tcp"
    cidr_blocks = var.default_ingress
  }

  ingress {
    description     = "Ingress for applications"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks_sg.id, aws_security_group.eks_sg.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.default_egress
  }

  tags = merge(var.tags, tomap({
    Name = "${var.namespace}-${var.environment}-db-sg"
  }))
}
