
################################################################
## defaults
################################################################
provider "aws" {
  region = var.region
}

module "tags" {
  source = "git::https://github.com/sourcefuse/terraform-aws-refarch-tags.git?ref=1.1.0"

  environment = terraform.workspace
  project     = "refarch-devops-infra"

  extra_tags = {
    MonoRepo     = "True"
    MonoRepoPath = "terraform/resources/network"
  }
}

################################################################
## network
################################################################
module "network" {
  source             = "../."
  namespace          = var.namespace
  tags               = module.tags.tags
  availability_zones = var.availability_zones
  vpc_cidr_block     = var.vpc_cidr_block
  environment        = var.environment
}
