variable "environment" {
  type        = string
  description = "Environmenr name"
}

variable "namespace" {
  description = "Namespace name"
  type        = string
}

variable "name" {
  type        = string
  description = "VPC name"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC. Can be 'default' or 'dedicated'."
  type        = string
  default     = "default"
}

variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "assign_generated_ipv6_cidr_block" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC."
  type        = bool
  default     = false
}

variable "ipv6_ipam_pool_id" {
  description = "The IPv6 IPAM pool ID from which to allocate the CIDR."
  type        = string
  default     = null # Set to null if not using IPAM for IPv6 allocation
}

variable "ipv6_netmask_length" {
  description = "The netmask length of the IPv6 CIDR block to allocate to the VPC."
  type        = number
  default     = null # Set to null if not using IPv6 CIDR block
}

variable "ipv4_ipam_pool_id" {
  description = "The IPv4 IPAM pool ID from which to allocate the CIDR."
  type        = string
  default     = null # Set to null if not using IPAM for IPv4 allocation
}

variable "ipv4_netmask_length" {
  description = "The netmask length of the IPv4 CIDR block to allocate to the VPC."
  type        = number
  default     = null # Set to null if not using IPv4 IPAM
}

variable "enable_network_address_usage_metrics" {
  description = "Enable or disable network address usage metrics."
  type        = bool
  default     = false # Set the default value, can be overridden
}

variable "ipv6_cidr_block" {
  description = "The IPv6 CIDR block to associate with your VPC."
  type        = string
  default     = null # Set as null by default, can be overridden
}

variable "ipv6_cidr_block_network_border_group" {
  description = "The network border group of the IPv6 CIDR block."
  type        = string
  default     = null # Set as null by default, can be overridden
}


variable "create_internet_geteway" {
  type        = bool
  description = "(optional) Whether to create internet gateway"
  default     = true
}

variable "internet_geteway_name" {
  type        = string
  description = "(optional) If the Internet Gateway name is not provided, it will be automatically derived."
  default     = null
}

# Variable to define a map of subnets with their attributes
variable "subnet_map" {
  type = map(object({
    name                                           = string
    cidr_block                                     = string
    availability_zone                              = string
    enable_resource_name_dns_a_record_on_launch    = optional(bool, false)
    enable_resource_name_dns_aaaa_record_on_launch = optional(bool, false)
    map_public_ip_on_launch                        = optional(bool, false)
    ipv6_native                                    = optional(bool, false)
    assign_ipv6_address_on_creation                = optional(bool, false)
    ipv6_cidr_block                                = optional(string, null)
    enable_dns64                                   = optional(bool, false)
    nat_gateway_name                               = optional(string, null)
    create_nat_gateway                             = optional(bool, true)
    attach_nat_gateway                             = optional(bool, false)
    attach_internet_gateway                        = optional(bool, false)
    additional_routes = optional(list(object({
      type                        = optional(string, "transit-gateway") // possible values : network-interface ,transit-gateway, vpc-endpoint, vpc-peering-connection
      id                          = string
      destination_cidr_block      = optional(string, null)
      destination_ipv6_cidr_block = optional(string, null)
      }
    )), [])
  }))
  default     = null
  description = <<-EOT
    A map defining the configuration of subnets, their attributes, and associated resources.
    Each subnet configuration can include the following details:

    - **name**: Name of the subnet.
    - **cidr_block**: CIDR block for the subnet.
    - **availability_zone**: The availability zone where the subnet is located.
    - **enable_resource_name_dns_a_record_on_launch**: Enable or disable DNS A records for EC2 instances launched in this subnet (default: false).
    - **enable_resource_name_dns_aaaa_record_on_launch**: Enable or disable DNS AAAA records for EC2 instances launched in this subnet (default: false).
    - **map_public_ip_on_launch**: Specify whether to auto-assign a public IP for instances in this subnet (default: false).
    - **ipv6_native**: Enable or disable native IPv6 support for the subnet (default: false).
    - **assign_ipv6_address_on_creation**: Whether to automatically assign an IPv6 address to instances launched in the subnet (default: false).
    - **ipv6_cidr_block**: The IPv6 CIDR block associated with the subnet (optional).
    - **enable_dns64**: Enable or disable DNS64 in the subnet (default: false).
    - **nat_gateway_name**: Name of the NAT Gateway attached to the subnet (optional).
    - **create_nat_gateway**: Specify whether to create a NAT Gateway for the subnet (default: true).
    - **attach_nat_gateway**: Specify whether to attach an existing NAT Gateway to the subnet (default: false).
    - **attach_internet_gateway**: Specify whether to attach an Internet Gateway to the subnet (default: false).
    - **additional_routes**: List of additional routes to be added to the subnet route table, typically to route traffic to other services like Transit Gateway. Each route includes:
      - **type**: Type of resource (default: "transit-gateway").
      - **id**: The ID of the route target (e.g., a Transit Gateway ID).
      - **cidr_block**: The destination CIDR block for the route.
      - **destination_ipv6_cidr_block**: The destination IPV6 CIDR block for the route.
  EOT
}

variable "vpc_endpoint_data" {
  type = list(object({
    service             = string
    route_table_filter  = optional(string, "private") // possible values 'private' and 'public'
    policy_doc          = optional(string, null)
    private_dns_enabled = optional(bool, false)
    security_group_ids  = optional(list(string), [])
  }))
  description = "(optional) List of VPC endpoints to be created"
  default     = []
}

variable "availability_zones" {
  type        = list(string)
  description = "(optional) List of availability zones , if subnet map is null , subnet map autimatically derived"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "(optional) Tags for VPC resources"
  default     = {}
}
variable "kms_config" {
  type = object({
    deletion_window_in_days = number
    enable_key_rotation     = bool
  })
  default = {
    deletion_window_in_days = 30
    enable_key_rotation     = true
  }
}

# Variable for VPC Flow Log Configuration
variable "vpc_flow_log_config" {
  description = "Configuration settings for VPC flow logs."
  type = object({
    enable_to_cloudwatch = bool   # Enable VPC flow logs to CloudWatch
    retention_in_days    = number # Retention period in CloudWatch
    enable_to_s3         = bool   # Enable VPC flow logs to S3
    bucket_arn           = string # S3 bucket ARN for VPC flow logs (if enabled)
  })
  default = {
    enable_to_cloudwatch = false
    retention_in_days    = 7
    enable_to_s3         = false
    bucket_arn           = null
  }
}
