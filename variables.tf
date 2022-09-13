variable "environment" {
  type        = string
  description = "Name of the environment, i.e. dev, stage, prod"
  default     = "dev"
}

variable "namespace" {
  type        = string
  description = "Namespace of the project, i.e. refarch"
  default     = "refarch"
}

variable "tags" {
  type        = map(string)
  description = "Default tags to apply to every resource"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to deploy resources in."
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC to use."
}

variable "default_ingress" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Default ingress CIDR"
}

variable "default_egress" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Default egress CIDR"
}
