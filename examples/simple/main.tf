################################################################
## defaults
################################################################
terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.3"

  environment = var.environment
  project     = "terraform-aws-ref-arch-network"

  extra_tags = {
    Example = "True"
  }
}

################################################################
## network
################################################################
module "network" {
  source                      = "sourcefuse/arc-network/aws"
  version                     = "2.4.2"
  namespace                   = var.namespace
  environment                 = var.environment
  availability_zones          = var.availability_zones
  vpc_ipv4_primary_cidr_block = var.vpc_ipv4_primary_cidr_block
  client_vpn_enabled          = false
  tags                        = module.tags.tags
  client_vpn_authorization_rules = [
    {
      target_network_cidr  = var.vpc_ipv4_primary_cidr_block
      authorize_all_groups = true
      description          = "default authorization group to allow all authenticated clients to access the vpc"
    }
  ]

  vpc_endpoint_config = {
    s3         = true
    kms        = false
    cloudwatch = false
    elb        = false
    dynamodb   = true
    ec2        = false
    sns        = true
    sqs        = true
    ecs        = true
    rds        = true
  }
  gateway_endpoint_route_table_filter = ["*private*"]
}
