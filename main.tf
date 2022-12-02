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
