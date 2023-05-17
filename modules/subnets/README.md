# Terraform Module: Subnets  

## Overview

AWS Subnets for the ARC Infrastructure.  

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_default_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_eip.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_nat_gateway.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_route.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_az_ngw_ids"></a> [az\_ngw\_ids](#input\_az\_ngw\_ids) | Only for private subnets. Map of AZ names to NAT Gateway IDs that are used as default routes when creating private subnets.<br>You should either supply one NAT Gateway ID for each AZ in `var.availability_zones` or leave the map empty.<br>If empty, no default egress route will be created and you will have to create your own using `aws_route`. | `map(string)` | `{}` | no |
| <a name="input_create_aws_network_acl"></a> [create\_aws\_network\_acl](#input\_create\_aws\_network\_acl) | This indicates whether to create aws network acl or not | `bool` | n/a | yes |
| <a name="input_default_network_acl_id"></a> [default\_network\_acl\_id](#input\_default\_network\_acl\_id) | Network ACL ID to manage. This attribute is exported from aws\_vpc, or manually found via the AWS Console. | `string` | n/a | yes |
| <a name="input_igw_id"></a> [igw\_id](#input\_igw\_id) | Internet Gateway ID that is used as a default route when creating public subnets (e.g. `igw-9c26a123`) | `string` | `""` | no |
| <a name="input_nat_gateway_enabled"></a> [nat\_gateway\_enabled](#input\_nat\_gateway\_enabled) | Enable the NAT Gateway between public and private subnets | `bool` | `true` | no |
| <a name="input_private_network_acl_egress"></a> [private\_network\_acl\_egress](#input\_private\_network\_acl\_egress) | Egress network ACL rules | <pre>list(object({<br>    rule_no         = number<br>    action          = string<br>    cidr_block      = string<br>    from_port       = number<br>    to_port         = number<br>    protocol        = string<br>    icmp_code       = optional(string, null)<br>    icmp_type       = optional(string, null)<br>    ipv6_cidr_block = optional(string, null)<br>  }))</pre> | <pre>[<br>  {<br>    "action": "allow",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_private_network_acl_ingress"></a> [private\_network\_acl\_ingress](#input\_private\_network\_acl\_ingress) | Ingress network ACL rules | <pre>list(object({<br>    rule_no         = number<br>    action          = string<br>    cidr_block      = string<br>    from_port       = number<br>    to_port         = number<br>    protocol        = string<br>    icmp_code       = optional(string, null)<br>    icmp_type       = optional(string, null)<br>    ipv6_cidr_block = optional(string, null)<br>  }))</pre> | <pre>[<br>  {<br>    "action": "allow",<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "rule_no": 100,<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_private_network_acl_subnet_ids"></a> [private\_network\_acl\_subnet\_ids](#input\_private\_network\_acl\_subnet\_ids) | Private network ACL Subnet IDs. This is typically unused due to using the `default_network_acl_id`. | `list(string)` | `[]` | no |
| <a name="input_private_route_table_additional_tags"></a> [private\_route\_table\_additional\_tags](#input\_private\_route\_table\_additional\_tags) | Additional tags to add to the private route table | `map(string)` | `{}` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnets to add to the VPC | <pre>list(object({<br>    name              = string<br>    availability_zone = string<br>    cidr_block        = string<br>    tags              = optional(map(string), {})<br>  }))</pre> | n/a | yes |
| <a name="input_public_route_table_additional_tags"></a> [public\_route\_table\_additional\_tags](#input\_public\_route\_table\_additional\_tags) | Additional tags to add to the public route table | `map(string)` | `{}` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | List of public subnets to add to the VPC | <pre>list(object({<br>    name                    = string<br>    availability_zone       = string<br>    cidr_block              = string<br>    map_public_ip_on_launch = optional(bool, false)<br>    igw_id                  = optional(string, "")<br>    tags                    = optional(map(string), {})<br>  }))</pre> | n/a | yes |
| <a name="input_route_table_association_enabled"></a> [route\_table\_association\_enabled](#input\_route\_table\_association\_enabled) | If the route table has an association. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags to apply to every resource | `map(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to create the cluster in (e.g. `vpc-a22222ee`) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | Map of AZ names to Route Table IDs |
| <a name="output_private_subnet_arns"></a> [private\_subnet\_arns](#output\_private\_subnet\_arns) | Map of AZ names to subnet ARNs |
| <a name="output_private_subnet_cidr_blocks"></a> [private\_subnet\_cidr\_blocks](#output\_private\_subnet\_cidr\_blocks) | Map of AZ names to subnet CIDR blocks |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | Map of AZ names to subnet IDs |
| <a name="output_public_ngw_ids"></a> [public\_ngw\_ids](#output\_public\_ngw\_ids) | Map of AZ names to NAT Gateway IDs (only for public subnets) |
| <a name="output_public_route_table_ids"></a> [public\_route\_table\_ids](#output\_public\_route\_table\_ids) | Map of AZ names to Route Table IDs |
| <a name="output_public_subnet_arns"></a> [public\_subnet\_arns](#output\_public\_subnet\_arns) | Map of AZ names to subnet ARNs |
| <a name="output_public_subnet_cidr_blocks"></a> [public\_subnet\_cidr\_blocks](#output\_public\_subnet\_cidr\_blocks) | Map of AZ names to subnet CIDR blocks |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Map of AZ names to subnet IDs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
