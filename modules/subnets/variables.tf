################################################################################
## shared
################################################################################
variable "vpc_id" {
  type        = string
  description = "VPC ID to create the cluster in (e.g. `vpc-a22222ee`)"
}

variable "tags" {
  type        = map(string)
  description = "Default tags to apply to every resource"
}

################################################################################
## default
################################################################################
variable "private_network_acl_subnet_ids" {
  type        = list(string)
  description = "Private network ACL Subnet IDs. This is typically unused due to using the `default_network_acl_id`."
  default     = []
}

################################################################################
## private
################################################################################
variable "nat_gateway_enabled" {
  description = "Enable the NAT Gateway between public and private subnets"
  type        = bool
  default     = true
}

variable "private_subnets" {
  description = "List of private subnets to add to the VPC"
  type = list(object({
    name              = string
    availability_zone = string
    cidr_block        = string
    tags              = optional(map(string), {})
  }))
}

variable "private_network_acl_ingress" {
  description = "Ingress network ACL rules"
  type = list(object({
    rule_no         = number
    action          = string
    cidr_block      = string
    from_port       = number
    to_port         = number
    protocol        = string
    icmp_code       = optional(string, null)
    icmp_type       = optional(string, null)
    ipv6_cidr_block = optional(string, null)
  }))

  default = [
    {
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
    },
  ]
}

variable "private_network_acl_egress" {
  description = "Egress network ACL rules"
  type = list(object({
    rule_no         = number
    action          = string
    cidr_block      = string
    from_port       = number
    to_port         = number
    protocol        = string
    icmp_code       = optional(string, null)
    icmp_type       = optional(string, null)
    ipv6_cidr_block = optional(string, null)
  }))

  default = [
    {
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
    },
  ]
}

variable "az_ngw_ids" {
  type        = map(string)
  description = <<-EOT
    Only for private subnets. Map of AZ names to NAT Gateway IDs that are used as default routes when creating private subnets.
    You should either supply one NAT Gateway ID for each AZ in `var.availability_zones` or leave the map empty.
    If empty, no default egress route will be created and you will have to create your own using `aws_route`.
  EOT
  default     = {}
}

################################################################################
## public
################################################################################
variable "route_table_association_enabled" {
  description = "If the route table has an association."
  type        = bool
  default     = true
}

variable "public_route_table_additional_tags" {
  description = "Additional tags to add to the public route table"
  type        = map(string)
  default     = {}
}

variable "private_route_table_additional_tags" {
  description = "Additional tags to add to the private route table"
  type        = map(string)
  default     = {}
}

variable "public_subnets" {
  description = "List of public subnets to add to the VPC"
  type = list(object({
    name                    = string
    availability_zone       = string
    cidr_block              = string
    map_public_ip_on_launch = optional(bool, false)
    igw_id                  = optional(string, "")
    tags                    = optional(map(string), {})
  }))
}

variable "igw_id" {
  type        = string
  description = "Internet Gateway ID that is used as a default route when creating public subnets (e.g. `igw-9c26a123`)"
  default     = ""
}

variable "create_aws_network_acl" {
  type        = bool
  description = "This indicates whether to create aws network acl or not"
}
