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
variable "vpc_name_override" {
  type        = string
  description = <<-EOT
    VPC Name override. If left undefined, this will use the naming convention of
    `namespace-environment-vpc`.
  EOT
  default     = null
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

variable "auto_generate_multi_az_subnets" {
  type        = bool
  description = <<-EOT
    Auto-generate subnets in defined availability zones. This value is overridden if the variable `custom_subnets_enabled`
    is set to `true`. This is to avoid conflicts within the VPC network configuration.
  EOT
  default     = true
}

## custom subnets
variable "custom_subnets_enabled" {
  type        = bool
  description = <<-EOT
    Set to `true` to allow custom subnet configuration.
    If this is set to `true`, the variable `auto_generate_multi_az_subnets` will be overridden and not create the
    multi-az subnets.
  EOT
  default     = false
}

variable "custom_private_subnets" {
  description = "List of private subnets to add to the VPC"
  type = list(object({
    name              = string
    availability_zone = string
    cidr_block        = string
    tags              = optional(map(string), {})
  }))
  default = []
}

variable "custom_public_subnets" {
  description = "List of public subnets to add to the VPC"
  type = list(object({
    name                    = string
    availability_zone       = string
    cidr_block              = string
    map_public_ip_on_launch = optional(bool, false)
    igw_id                  = optional(string, "")
    tags                    = optional(map(string), {})
  }))
  default = []
}

variable "custom_create_aws_network_acl" {
  type        = bool
  description = "This indicates whether to create aws network acl or not"
  default     = false
}

variable "custom_nat_gateway_enabled" {
  description = "Enable the NAT Gateway between public and private subnets"
  type        = bool
  default     = true
}

variable "custom_private_network_acl_ingress" {
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

variable "custom_private_network_acl_egress" {
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

variable "custom_private_network_acl_subnet_ids" {
  type        = list(string)
  description = "Private network ACL Subnet IDs. This is typically unused due to using the `default_network_acl_id`."
  default     = []
}

variable "custom_az_ngw_ids" {
  type        = map(string)
  description = <<-EOT
    Only for private subnets. Map of AZ names to NAT Gateway IDs that are used as default routes when creating private subnets.
    You should either supply one NAT Gateway ID for each AZ in `var.availability_zones` or leave the map empty.
    If empty, no default egress route will be created and you will have to create your own using `aws_route`.
  EOT
  default     = {}
}

variable "custom_route_table_association_enabled" {
  description = "If the route table has an association."
  type        = bool
  default     = true
}

variable "custom_public_route_table_additional_tags" {
  description = "Additional tags to add to the public route table"
  type        = map(string)
  default     = {}
}

variable "custom_private_route_table_additional_tags" {
  description = "Additional tags to add to the private route table"
  type        = map(string)
  default     = {}
}

################################################################################
## vpn
################################################################################
variable "client_vpn_name_override" {
  type        = string
  description = <<-EOT
    Client VPN Name override. If left undefined, this will use the naming convention of
    `namespace-environment-client-vpn`.
  EOT
  default     = null
}

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

variable "ec2_endpoint_name_override" {
  type        = string
  description = <<-EOT
     EC2 endpoint name. If left undefined, this will use the naming convention of
    `namespace-environment-ec2-endpoint`.
  EOT
  default     = null
}

variable "s3_endpoint_name_override" {
  type        = string
  description = <<-EOT
     S3 endpoint name. If left undefined, this will use the naming convention of
    `namespace-environment-s3-endpoint`.
  EOT
  default     = null
}

variable "dynamodb_endpoint_name_override" {
  type        = string
  description = <<-EOT
     DynamoDB endpoint name. If left undefined, this will use the naming convention of
    `namespace-environment-dynamodb-endpoint`.
  EOT
  default     = null
}

variable "public_subnet_name_override" {
  type        = string
  description = <<-EOT
     Public Subnets name. If left undefined, this will use the naming convention of
    `namespace-environment-public-subnet`.
  EOT
  default     = null
}

variable "private_subnet_name_override" {
  type        = string
  description = <<-EOT
     Private Subnets name. If left undefined, this will use the naming convention of
    `namespace-environment-private-subnet`.
  EOT
  default     = null
}

variable "kms_endpoint_name_override" {
  type        = string
  description = <<-EOT
     KMS Endpoint name. If left undefined, this will use the naming convention of
    `namespace-environment-kms-endpoint.
  EOT
  default     = null
}

variable "elb_endpoint_name_override" {
  type        = string
  description = <<-EOT
    ELB endpoint name. If left undefined, this will use the naming convention of
    `namespace-environment-elb-endpoint`.
  EOT
  default     = null
}

variable "cloudwatch_endpoint_name_override" {
  type        = string
  description = <<-EOT
    CloudWatch endpoint name. If left undefined, this will use the naming convention of
    `namespace-environment-cloudwatch-endpoint`.
  EOT
  default     = null
}

variable "sqs_endpoint_name_override" {
  type        = string
  description = <<-EOT
    SQS endpoint name. If left undefined, this will use the naming convention of
    `namespace-environment-sqs-endpoint`.
  EOT
  default     = null
}

variable "sns_endpoint_name_override" {
  type        = string
  description = <<-EOT
    SNS endpoint name. If left undefined, this will use the naming convention of
    `namespace-environment-sns-endpoint`.
  EOT
  default     = null
}

variable "ecs_endpoint_name_override" {
  type        = string
  description = <<-EOT
    ECS endpoint name. If left undefined, this will use the naming convention of
    `namespace-environment-ecs-endpoint`.
  EOT
  default     = null
}

variable "rds_endpoint_name_override" {
  type        = string
  description = <<-EOT
    RDS endpoint name. If left undefined, this will use the naming convention of
    `namespace-environment-rds-endpoint`.
  EOT
  default     = null
}

variable "private_dns_enabled" {
  type        = bool
  description = "Whether to enable Private DNS for the endpoint(s)"
  default     = true
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
    sns        = false
    sqs        = false
    ecs        = false
    rds        = false
  }
}

variable "gateway_endpoint_route_table_filter" {
  type        = list(string)
  description = "List of strings to filter route tables , eg [ '*private*' , '*public*' ]"
  default     = []
}

variable "vpc_endpoint_type" {
  type        = string
  description = "The VPC endpoint type, Gateway, GatewayLoadBalancer, or Interface."
  default     = "Interface"
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

variable "aws_dx_connection_name_override" {
  type        = string
  description = <<-EOT
    AWS DX Connection. If left undefined, this will use the naming convention of
    `namespace-environment-dx-connection`.
  EOT
  default     = null
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
