provider "aws" {
  region                  = var.region
  profile                 = var.profile
  shared_credentials_file = "${pathexpand("~/.aws/credentials")}"

  assume_role {
    role_arn = "arn:aws:iam::757583164619:role/sourcefuse-poc-2-admin-role"
  }
}


