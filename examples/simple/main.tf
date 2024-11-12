################################################################
## defaults
################################################################
terraform {
  required_version = "~> 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
  source = "../../"

  namespace   = var.namespace
  environment = var.environment

  name                    = "arc-poc"
  create_internet_geteway = true
  vpc_flow_log_config = {
    enable_to_cloudwatch = true
    retention_in_days    = 7
    enable_to_s3         = false
    bucket_arn           = null
  }


  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  cidr_block         = "10.0.0.0/16"
  vpc_endpoint_data = [
    {
      service            = "s3"
      route_table_filter = "private"
    },
    {
      service            = "dynamodb"
      route_table_filter = "private"
    }
  ]

  tags = module.tags.tags
}
