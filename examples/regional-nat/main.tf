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
    Example = "regional-nat"
  }
}

################################################################
## network with regional NAT gateway (auto mode)
################################################################
module "network" {
  source = "../../"

  namespace   = var.namespace
  environment = var.environment

  name                    = "${var.namespace}-${var.environment}-regional"
  create_internet_gateway = true

  # Regional NAT Gateway configuration (auto mode)
  nat_gateway_config = {
    mode               = "regional"
    regional_auto_mode = true
  }

  ## Regional NAT Gateway configuration (with custom EIPs)
  # nat_gateway_config = {
  #   mode               = "regional"
  #   regional_auto_mode = false
  #   regional_az_eip_config = {
  #     "us-east-1a" = [aws_eip.regional_nat[0].allocation_id]
  #     "us-east-1b" = [aws_eip.regional_nat[1].allocation_id]
  #     "us-east-1c" = [aws_eip.regional_nat[2].allocation_id]
  #   }
  # }

  vpc_flow_log_config = {
    enable            = false
    retention_in_days = 7
    s3_bucket_arn     = null
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
  # tags = {
  #   Example = "regional-nat"
  # }
}
