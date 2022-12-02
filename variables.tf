################################################################################
## defaults
################################################################################
variable "environment" {
  type        = string
  description = "Name of the environment, i.e. dev, stage, prod"
}

variable "namespace" {
  type        = string
  description = "Namespace of the project, i.e. refarch"
}

variable "region" {
  description = "Region to deploy the resources in"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "Default tags to apply to every resource"
  default     = {}
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to deploy resources in."
}

variable "ipv4_primary_cidr_block" {
  type        = string
  description = "CIDR block for the VPC to use."
}

variable "default_ingress" {
  type        = list(string)
  description = "Default standard web ingress CIDR"
  default     = ["0.0.0.0/0"]
}

variable "default_egress" {
  type        = list(string)
  description = "Default egress CIDR"
  default     = ["0.0.0.0/0"]
}

################################################################################
## bastion
################################################################################
variable "enable_bastion_host" {
  description = "Enable a bastion host for access to private internal resources."
  type        = bool
  default     = false
}

variable "bastion_ami_owners" {
  description = "The list of owners used to select the AMI of action runner instances."
  type        = list(string)
  default     = ["amazon"]
}

variable "bastion_ami_filter" {
  description = "List of maps used to create the AMI filter for the action runner AMI."
  type        = map(list(string))

  default = {
    name = ["amzn2-ami-hvm-2.*-x86_64-ebs"]
  }
}

variable "authorized_ssh_cidr_blocks" {
  description = "A list of authorized CIDR blocks to access the bastion host."
  type        = list(string)
  default     = []
}
