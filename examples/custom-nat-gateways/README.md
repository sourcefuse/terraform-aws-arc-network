# Custom Subnet topology and nat gateway example

## Overview

The default behavior of the referenced module is to create the public and private subnets dynamically via VPC CIDR and the Availability Zone count
along with custom nat gateway resource.  
This example shows how to pass in custom subnet configuration, overriding the default behavior of the module.  

## Nat gateway considerations

If you have disabled the default nat gateways for your custom subnets
then you need to pass a nat gateway id for each private subnet that
you are creating. If custom_az_ngw_ids is left empty in this case
then no default route is created by the module.
Creating nat gateway as demonstrated in this example is a 3 step process

- STEP 1 : Apply the configuration without any nat gateway and eip resources and without custom_az_ngw_ids value
- STEP 2 : Add nat gateway and eip resources and run apply
- STEP 3 : finally add custom_az_ngw_ids input map and run apply

This does introduce a cyclical dependency between the network module and the nat and eip resources, but it is expected
since its a deviation from the [recommended aws nat gateway configuration](https://aws.amazon.com/blogs/networking-and-content-delivery/using-nat-gateways-with-multiple-amazon-vpcs-at-scale/).
<details><summary>tldr</summary>

NAT Gateways within an AZ are automatically implemented with redundancy. However, while Amazon VPCs can span multiple AZs, each NAT Gateway operates within a single AZ. If the NAT Gateway fails, then connections with resources using that NAT Gateway also fail. Therefore, we recommend deploying one NAT Gateway in each AZ and routing traffic locally within the same AZ.

</details>

Handling multiple scenarios for nat gateway routes in the module does not seems feasible. Hence the mapping of nat gateways to availability zones is off-loaded to the end user of the module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_awsutils"></a> [awsutils](#requirement\_awsutils) | ~> 0.18 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.35.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network"></a> [network](#module\_network) | ../../ | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.3 |

## Resources

| Name | Type |
|------|------|
| [aws_eip.nat_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_nat_gateway.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones to deploy resources in. | `list(string)` | <pre>[<br>  "us-east-1a",<br>  "us-east-1b"<br>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment, i.e. dev, stage, prod | `string` | `"dev"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace of the project, i.e. refarch | `string` | `"example"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | `"us-east-1"` | no |
| <a name="input_vpc_ipv4_primary_cidr_block"></a> [vpc\_ipv4\_primary\_cidr\_block](#input\_vpc\_ipv4\_primary\_cidr\_block) | IPv4 CIDR block for the VPC to use. | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | private subnets per availibility zones |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | public subnets per az |
| <a name="output_vpn_endpoint_dns_name"></a> [vpn\_endpoint\_dns\_name](#output\_vpn\_endpoint\_dns\_name) | The DNS Name of the Client VPN Endpoint Connection. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
