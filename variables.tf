################################################################################
## shared
################################################################################
variable "environment" {
  type        = string
  description = "Name of the environment, i.e. dev, stage, prod"
}

variable "namespace" {
  type        = string
  description = "Namespace of the project, i.e. refarch"
}

variable "tags" {
  type        = map(string)
  description = "Default tags to apply to every resource"
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Specify region for VPC endpoints"
}

################################################################################
## vpc
################################################################################
variable "vpc_name" {
  type        = string
  description = "VPC Name"
  default     = "vpc"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to deploy resources in."
}

variable "vpc_ipv4_primary_cidr_block" {
  type        = string
  description = "IPv4 CIDR block for the VPC to use."
}

variable "default_network_acl_deny_all" {
  type        = bool
  default     = false
  description = <<-EOT
    When `true`, manage the default network acl and remove all rules, disabling all ingress and egress.
    When `false`, do not mange the default networking acl, allowing it to be managed by another component.
    EOT
}

variable "default_route_table_no_routes" {
  type        = bool
  default     = false
  description = <<-EOT
    When `true`, manage the default route table and remove all routes, disabling all ingress and egress.
    When `false`, do not mange the default route table, allowing it to be managed by another component.
    Conflicts with Terraform resource `aws_main_route_table_association`.
    EOT
}

variable "internet_gateway_enabled" {
  type        = bool
  description = "Set `true` to create an Internet Gateway for the VPC"
  default     = true
}

variable "dns_hostnames_enabled" {
  type        = bool
  description = "Set `true` to enable [DNS hostnames](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html#vpc-dns-hostnames) in the VPC"
  default     = true
}

variable "dns_support_enabled" {
  type        = bool
  description = "Set `true` to enable DNS resolution in the VPC through the Amazon provided DNS server"
  default     = true
}

variable "default_security_group_deny_all" {
  type        = bool
  default     = true
  description = <<-EOT
    When `true`, manage the default security group and remove all rules, disabling all ingress and egress.
    When `false`, do not manage the default security group, allowing it to be managed by another component.
    EOT
}

variable "assign_generated_ipv6_cidr_block" {
  type        = bool
  description = "When `true`, assign AWS generated IPv6 CIDR block to the VPC.  Conflicts with `ipv6_ipam_pool_id`."
  default     = true
}

variable "ipv6_egress_only_internet_gateway_enabled" {
  type        = bool
  description = "Set `true` to create an IPv6 Egress-Only Internet Gateway for the VPC"
  default     = false
}

################################################################################
## vpn
################################################################################
variable "vpn_gateway_enabled" {
  type        = bool
  description = "Enable VPN Gateway."
  default     = false
}

variable "client_vpn_enabled" {
  type        = bool
  description = "Enable client VPN endpoint"
  default     = false
}

variable "client_vpn_organization_name" {
  type        = string
  description = "Organization name for self signed certificates"
  default     = ""
}

variable "client_vpn_client_cidr_block" {
  type        = string
  description = "CIDR block to be assigned tpo VPN clients"
  default     = "10.1.0.0/16"
}

variable "client_vpn_logging_enabled" {
  type        = bool
  description = "Enable/disable CloudWatch logs for client VPN"
  default     = true
}

variable "client_vpn_retention_in_days" {
  type        = number
  description = "Number of days to retain the client VPN logs on CloudWatch"
  default     = 30
}

variable "client_vpn_split_tunnel" {
  type        = bool
  description = "Enable/disable split tunnel"
  default     = true
}

variable "client_vpn_create_security_group" {
  type        = bool
  default     = true
  description = "Set `true` to create and configure a new security group. If false, `associated_security_group_ids` must be provided."
}

variable "client_vpn_associated_security_group_ids" {
  type        = list(string)
  default     = []
  description = <<-EOT
    A list of IDs of Security Groups to associate the VPN endpoints with, in addition to the created security group.
    These security groups will not be modified and, if `create_security_group` is `false`, must have rules providing the desired access.
    EOT
}

variable "client_vpn_allowed_security_group_ids" {
  type        = list(string)
  default     = []
  description = <<-EOT
    A list of IDs of Security Groups to allow access to the security group created by this module.
    The length of this list must be known at "plan" time.
    EOT
}
variable "client_vpn_authorization_rules" {
  type        = list(map(any))
  description = "List of objects describing the authorization rules for the client vpn"
}
################################################################################
## vpc endpoint
################################################################################
variable "vpc_endpoints_enabled" {
  type        = bool
  description = "Enable VPC endpoints."
  default     = false
}

variable "private_dns_enabled" {
  type    = bool
  default = true
}

variable "vpc_endpoint_config" {
  type        = map(bool)
  description = "Map variable that toggles the enablement of an application"
  default = {
    s3         = false
    kms        = false
    cloudwatch = false
    elb        = false
    dynamodb   = false
    ec2        = false
  }
}

variable "vpc_endpoint_type" {
  type    = string
  default = "Interface"
}

variable "gateway_vpc_endpoints" {
  type = map(object({
    name            = string
    policy          = string
    route_table_ids = list(string)
  }))
  description = <<-EOT
    A map of Gateway VPC Endpoints to provision into the VPC. This is a map of objects with the following attributes:
    - `name`: Short service name (either "s3" or "dynamodb")
    - `policy` = A policy (as JSON string) to attach to the endpoint that controls access to the service. May be `null` for full access.
    - `route_table_ids`: List of route tables to associate the gateway with. Routes to the gateway
      will be automatically added to these route tables.
    EOT
  default     = {}
}

variable "interface_vpc_endpoints" {
  type = map(object({
    name                = string
    policy              = string
    private_dns_enabled = bool
    security_group_ids  = list(string)
    subnet_ids          = list(string)
  }))
  description = <<-EOT
    A map of Interface VPC Endpoints to provision into the VPC.
    This is a map of objects with the following attributes:
    - `name`: Simple name of the service, like "ec2" or "redshift"
    - `policy`: A policy (as JSON string) to attach to the endpoint that controls access to the service. May be `null` for full access.
    - `private_dns_enabled`: Set `true` to associate a private hosted zone with the specified VPC
    - `security_group_ids`: The ID of one or more security groups to associate with the network interface. The first
      security group will replace the default association with the VPC's default security group. If you want
      to maintain the association with the default security group, either leave `security_group_ids` empty or
      include the default security group ID in the list.
    - `subnet_ids`: List of subnet in which to install the endpoints.
   EOT
  default     = {}
}

################################################################################
## direct connect
################################################################################
variable "direct_connect_enabled" {
  description = "Enable direct connect."
  type        = bool
  default     = false
}

variable "direct_connect_bandwidth" {
  description = <<-EOT
    The bandwidth of the connection.
    Valid values for dedicated connections: 1Gbps, 10Gbps.
    Valid values for hosted connections: 50Mbps, 100Mbps, 200Mbps, 300Mbps, 400Mbps, 500Mbps, 1Gbps, 2Gbps, 5Gbps, 10Gbps and 100Gbps.
    Case sensitive.
  EOT
  type        = string
  default     = "10Gbps"
}

variable "direct_connect_provider" {
  description = "The name of the service provider associated with the connection."
  type        = string
  default     = null
}

variable "direct_connect_location" {
  description = "The location of AWS Direct Connect. Use `aws directconnect describe-locations` for the list of AWS Direct Connect locations. Use locationCode for the value."
  type        = string
  default     = null
}

variable "direct_connect_request_macsec" {
  description = <<-EOT
    Boolean value indicating whether you want the connection to support MAC Security (MACsec).
    MAC Security (MACsec) is only available on dedicated connections.
    Changing this value will cause the resource to be destroyed and re-created.
    See [MACsec prerequisites](https://docs.aws.amazon.com/directconnect/latest/UserGuide/direct-connect-mac-sec-getting-started.html) for more information.
  EOT
  type        = bool
  default     = false
}

variable "direct_connect_encryption_mode" {
  description = "The connection MAC Security (MACsec) encryption mode. MAC Security (MACsec) is only available on dedicated connections. Valid values are no_encrypt, should_encrypt, and must_encrypt."
  type        = string
  default     = "must_encrypt"
}

variable "direct_connect_skip_destroy" {
  description = "et to true if you do not wish the connection to be deleted at destroy time, and instead just removed from the Terraform state."
  type        = bool
  default     = false
}
