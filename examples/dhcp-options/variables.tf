variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "namespace" {
  type        = string
  description = "Namespace name"
  default     = "arc"
}

variable "name" {
  type        = string
  description = "VPC name"
  default     = "dhcp-test"
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}
