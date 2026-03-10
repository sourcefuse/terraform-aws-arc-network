# Regional NAT Gateway Example

This example demonstrates how to use the terraform-aws-arc-network module with Regional NAT Gateway.

## Overview

Regional NAT Gateway is a multi-AZ NAT Gateway that provides:
- **Cost savings**: Single NAT Gateway resource instead of one per AZ
- **Built-in redundancy**: Automatically spans multiple availability zones
- **Simplified management**: One resource to manage instead of multiple

## Usage

### Auto Mode (Recommended)

In auto mode, AWS automatically:
- Expands to new availability zones as needed
- Allocates Elastic IP addresses
- Manages scaling

```hcl
nat_gateway_config = {
  mode               = "regional"
  regional_auto_mode = true
}
```

### Manual Mode

For more control over EIP allocation per AZ:

```hcl
# First, create EIPs outside the module
resource "aws_eip" "nat" {
  count  = 3
  domain = "vpc"
}

# Then configure the module
nat_gateway_config = {
  mode               = "regional"
  regional_auto_mode = false
  regional_az_eip_config = {
    "us-east-1a" = [aws_eip.nat[0].allocation_id]
    "us-east-1b" = [aws_eip.nat[1].allocation_id]
    "us-east-1c" = [aws_eip.nat[2].allocation_id]
  }
}
```

## Important Notes

1. Regional NAT Gateway must be public (connectivity_type = "public")
2. Switching between auto and manual mode recreates the NAT Gateway
3. Regional NAT Gateway is only available in AWS regions that support it
4. Cannot be used with private connectivity type

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network"></a> [network](#module\_network) | ../../ | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.3 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"dev"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for resource naming | `string` | `"arc"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | Private subnet IDs |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Public subnet IDs |
| <a name="output_regional_nat_gateway_addresses"></a> [regional\_nat\_gateway\_addresses](#output\_regional\_nat\_gateway\_addresses) | Regional NAT Gateway addresses per AZ |
| <a name="output_regional_nat_gateway_id"></a> [regional\_nat\_gateway\_id](#output\_regional\_nat\_gateway\_id) | Regional NAT Gateway ID |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->