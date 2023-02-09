################################################################
## defaults
################################################################
terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9"
    }

    awsutils = {
      source  = "cloudposse/awsutils"
      version = "~> 0.15"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "awsutils" {
  region = var.region
}

module "tags" {
  source = "git::https://github.com/sourcefuse/terraform-aws-refarch-tags.git?ref=1.1.0"

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
  source = "../."

  namespace   = var.namespace
  environment = var.environment

  availability_zones              = var.availability_zones
  vpc_ipv4_primary_cidr_block     = var.vpc_ipv4_primary_cidr_block
  client_vpn_enabled              = true
  client_vpn_split_tunnel         = true
  vpn_self_service_portal_enabled = true

  tags = module.tags.tags
}
