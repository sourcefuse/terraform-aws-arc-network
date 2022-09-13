
################################################################
## defaults
################################################################
provider "aws" {
  region = var.region
}

module "tags" {
  source = "git@github.com:sourcefuse/terraform-aws-refarch-tags?ref=1.0.1"

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
  generate_ssh_key   = var.generate_ssh_key
  availability_zones = var.availability_zones
  region             = var.region
  security_groups    = []
  vpc_cidr_block     = var.vpc_cidr_block
  ssh_key_path       = var.ssh_key_path
  environment        = var.environment
  profile            = var.profile
}
