################################################################
## defaults
################################################################
terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    awsutils = {
      source  = "cloudposse/awsutils"
      version = "~> 0.18"
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
  source = "../../" #"sourcefuse/arc-network/aws"
  #version                     = "2.6.1"
  namespace                   = var.namespace
  environment                 = var.environment
  availability_zones          = var.availability_zones
  vpc_ipv4_primary_cidr_block = var.vpc_ipv4_primary_cidr_block
  client_vpn_enabled          = true

  ## custom subnets
  custom_subnets_enabled = true
  custom_private_subnets = [
    {
      name              = "${var.namespace}-${var.environment}-private-${var.region}a"
      availability_zone = "${var.region}a"
      cidr_block        = "10.0.0.0/19"
    },
    {
      name              = "${var.namespace}-${var.environment}-private-${var.region}b"
      availability_zone = "${var.region}b"
      cidr_block        = "10.0.64.0/19"
    }
  ]
  custom_public_subnets = [
    {
      name              = "${var.namespace}-${var.environment}-public-${var.region}a"
      availability_zone = "${var.region}a"
      cidr_block        = "10.0.96.0/20"
    },
    {
      name              = "${var.namespace}-${var.environment}-public-${var.region}b"
      availability_zone = "${var.region}b"
      cidr_block        = "10.0.112.0/20"
    }
  ]

  // If you have disabled the default nat gateways for your custom subnets
  // then you need to pass a nat gateway id for each private subnet that
  // you are creating. If custom_az_ngw_ids is left empty in this case
  // then no default route is created by the module.
  // Creating nat gateway as demonstrated in this example is a 3 step process
  // - STEP 1 : Apply the configuration without any nat gateway and eip resources and without custom_az_ngw_ids value
  // - STEP 2 : Add nat gateway and eip resources and run apply
  // - STEP 3 : finally add custom_az_ngw_ids input map and run apply

  custom_nat_gateway_enabled = false
  custom_az_ngw_ids = {
    "us-east-1a" = aws_nat_gateway.example.id
    "us-east-1b" = aws_nat_gateway.example.id
  }

  client_vpn_authorization_rules = [
    {
      target_network_cidr  = var.vpc_ipv4_primary_cidr_block
      authorize_all_groups = true
      description          = "default authorization group to allow all authenticated clients to access the vpc"
    }
  ]
  // if no vpc endpoint is required then you can remove this block with gateway_endpoint_route_table_filter
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

  tags = module.tags.tags
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = module.tags.tags
}
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = module.network.public_subnet_ids["${var.namespace}-${var.environment}-public-${var.region}a"]

  tags = merge({ Name = "${var.namespace}-${var.environment}-ngw" }, module.tags.tags)
}
