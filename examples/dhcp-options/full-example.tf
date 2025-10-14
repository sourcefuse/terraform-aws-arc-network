# Full DHCP Options Example (commented out to avoid conflicts)
# Uncomment and modify main.tf to use this configuration

/*
module "vpc_full_dhcp" {
  source = "../../"

  environment = var.environment
  namespace   = var.namespace
  name        = "${var.name}-full"
  cidr_block  = "10.1.0.0/16"

  dhcp_options_config = {
    domain_name                       = "service.consul"
    domain_name_servers               = ["127.0.0.1", "10.0.0.2"]
    ipv6_address_preferred_lease_time = 1440
    ntp_servers                       = ["127.0.0.1"]
    netbios_name_servers              = ["127.0.0.1"]
    netbios_node_type                 = 2
    tags = {
      Purpose = "Full DHCP Configuration"
      Type    = "Custom"
    }
  }

  tags = var.tags
}
*/
