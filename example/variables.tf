################################################################################
## defaults
################################################################################
variable "environment" {
  type        = string
  description = "Name of the environment, i.e. dev, stage, prod"
  default     = "dev"
}

variable "profile" {
  type        = string
  description = "AWS Config profile"
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "namespace" {
  type        = string
  description = "Namespace of the project, i.e. refarch"
  default     = "example"
}

################################################################################
## networking
################################################################################
variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to deploy resources in."
  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "ipv4_primary_cidr_block" {
  type        = string
  description = "CIDR block for the VPC to use."
  default     = "10.127.22.0/24"
}
