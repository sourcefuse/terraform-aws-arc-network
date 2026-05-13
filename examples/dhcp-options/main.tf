################################################################
## defaults
################################################################
terraform {
  required_version = "~> 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
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

module "vpc" {
  source = "../../"

  environment = var.environment
  namespace   = var.namespace
  name        = var.name
  cidr_block  = "10.0.0.0/16"

  dhcp_options_config = {
    domain_name         = "example.local"
    domain_name_servers = ["8.8.8.8", "8.8.4.4"]
    ntp_servers         = ["169.254.169.123"]
    netbios_node_type   = 2
    tags = {
      Purpose = "Custom DHCP Options"
    }
  }

  tags = module.tags.tags
}
