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

provider "aws" {
  region  = var.region
  profile = var.profile
}

module "tags" {
  source = "git::https://github.com/sourcefuse/terraform-aws-refarch-tags.git?ref=1.0.4"

  environment = var.environment
  project     = "terraform-aws-ref-arch-network"
}

################################################################################
## network
################################################################################
module "network" {
  source = "../."

  namespace   = var.namespace
  environment = var.environment
  region      = var.region

  ipv4_primary_cidr_block    = var.ipv4_primary_cidr_block
  availability_zones         = var.availability_zones
  enable_bastion_host        = true
  authorized_ssh_cidr_blocks = ["0.0.0.0/0"]

  tags = module.tags.tags
}
