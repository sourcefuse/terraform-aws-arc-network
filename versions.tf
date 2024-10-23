################################################################################
## defaults
################################################################################
terraform {
  required_version = ">= 1.3, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0, < 6.0"
    }

    awsutils = {
      source  = "cloudposse/awsutils"
      version = ">= 0.15"
    }
  }
}