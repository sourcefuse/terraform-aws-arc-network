terraform {
  required_version = ">= 1.0.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

################################################################################
## lookups
################################################################################
data "aws_ami" "bastion" {
  owners      = var.bastion_ami_owners
  most_recent = "true"

  dynamic "filter" {
    for_each = var.bastion_ami_filter

    content {
      name   = filter.key
      values = filter.value
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
  name        = "${var.namespace}-${var.environment}-alb-standard-web-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Standard web security group"

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

################################################################################
## bastion host
################################################################################
module "bastion_key_pair" {
  source = "git::https://github.com/cloudposse/terraform-aws-key-pair?ref=0.18.3"
  count  = var.enable_bastion_host == true ? 1 : 0

  namespace             = var.namespace
  stage                 = terraform.workspace
  name                  = "bastion"
  ssh_public_key_path   = "${path.root}/secrets"
  generate_ssh_key      = "true"
  private_key_extension = ".pem"
  public_key_extension  = ".pub"

  tags = var.tags
}

module "bastion" {
  source = "git::https://github.com/cloudposse/terraform-aws-ec2-instance?ref=0.45.1"
  count  = var.enable_bastion_host == true ? 1 : 0

  name              = "bastion"
  namespace         = var.namespace
  stage             = terraform.workspace
  vpc_id            = module.vpc.vpc_id
  region            = var.region
  instance_type     = "t3.micro"
  subnet            = module.public_subnets.az_subnet_ids[var.availability_zones[0]]
  ami               = data.aws_ami.bastion.id
  ami_owner         = data.aws_ami.bastion.owner_id
  ssh_key_pair      = module.bastion_key_pair[0].key_name
  availability_zone = var.availability_zones[0]

  ssm_patch_manager_enabled   = false
  assign_eip_address          = true
  associate_public_ip_address = true
  root_block_device_encrypted = true
  volume_tags_enabled         = true
  root_volume_size            = "25"
  root_volume_type            = "gp2"

  // the bastion is only allowed to connect to 3389. append additional rules. if needed.
  security_group_rules = [
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = var.authorized_ssh_cidr_blocks
    },
    {
      type        = "egress"
      from_port   = 3389
      to_port     = 3389
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  tags = var.tags
}
