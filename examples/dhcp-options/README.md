# VPC with Custom DHCP Options Example

This example demonstrates how to create a VPC with custom DHCP options using the terraform-aws-arc-network module.

## Features

- Creates a VPC with custom DHCP options
- Configures custom DNS servers (Google DNS: 8.8.8.8, 8.8.4.4)
- Sets custom domain name (example.local)
- Configures NTP server (AWS Time Sync Service)
- Sets NetBIOS node type to 2 (recommended by AWS)

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## DHCP Options Configuration

The example configures the following DHCP options:

- **domain_name**: `example.local` - Custom domain suffix
- **domain_name_servers**: `["8.8.8.8", "8.8.4.4"]` - Google DNS servers
- **ntp_servers**: `["169.254.169.123"]` - AWS Time Sync Service
- **netbios_node_type**: `2` - AWS recommended setting
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
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.3 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"dev"` | no |
| <a name="input_name"></a> [name](#input\_name) | VPC name | `string` | `"dhcp-test"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace name | `string` | `"arc"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dhcp_options_arn"></a> [dhcp\_options\_arn](#output\_dhcp\_options\_arn) | DHCP Options Set ARN |
| <a name="output_dhcp_options_id"></a> [dhcp\_options\_id](#output\_dhcp\_options\_id) | DHCP Options Set ID |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->