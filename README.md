# terraform-aws-ref-arch-network

## Overview

AWS Terraform module for the SourceFuse reference architecture network.

## Usage

This module is deployed with the following namespaces
* `dev`

SSH keys for the bastion host are stored in the S3 Terraform state bucket for the environment.

Initilize Terraform
```shell
terraform init
```

Create a `dev` workspace
```shell
terraform workspace new dev
```

Apply Terraform
```shell
terraform apply -var-file=dev.tfvars
```
 
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.44 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.44.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | git::https://github.com/cloudposse/terraform-aws-ec2-instance | 0.45.1 |
| <a name="module_bastion_key_pair"></a> [bastion\_key\_pair](#module\_bastion\_key\_pair) | git::https://github.com/cloudposse/terraform-aws-key-pair | 0.18.3 |
| <a name="module_private_subnets"></a> [private\_subnets](#module\_private\_subnets) | git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git | 0.15.0 |
| <a name="module_public_subnets"></a> [public\_subnets](#module\_public\_subnets) | git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git | 0.15.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | git::https://github.com/cloudposse/terraform-aws-vpc.git | 2.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.standard_web_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorized_ssh_cidr_blocks"></a> [authorized\_ssh\_cidr\_blocks](#input\_authorized\_ssh\_cidr\_blocks) | A list of authorized CIDR blocks to access the bastion host. | `list(string)` | `[]` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones to deploy resources in. | `list(string)` | n/a | yes |
| <a name="input_bastion_ami_filter"></a> [bastion\_ami\_filter](#input\_bastion\_ami\_filter) | List of maps used to create the AMI filter for the action runner AMI. | `map(list(string))` | <pre>{<br>  "name": [<br>    "amzn2-ami-hvm-2.*-x86_64-ebs"<br>  ]<br>}</pre> | no |
| <a name="input_bastion_ami_owners"></a> [bastion\_ami\_owners](#input\_bastion\_ami\_owners) | The list of owners used to select the AMI of action runner instances. | `list(string)` | <pre>[<br>  "amazon"<br>]</pre> | no |
| <a name="input_default_egress"></a> [default\_egress](#input\_default\_egress) | Default egress CIDR | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_default_ingress"></a> [default\_ingress](#input\_default\_ingress) | Default standard web ingress CIDR | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_enable_bastion_host"></a> [enable\_bastion\_host](#input\_enable\_bastion\_host) | Enable a bastion host for access to private internal resources. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment, i.e. dev, stage, prod | `string` | n/a | yes |
| <a name="input_ipv4_primary_cidr_block"></a> [ipv4\_primary\_cidr\_block](#input\_ipv4\_primary\_cidr\_block) | CIDR block for the VPC to use. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace of the project, i.e. refarch | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region to deploy the resources in | `string` | `"us-east-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags to apply to every resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#output\_private\_subnet\_cidrs) | Private subnet CIDRs |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | Private subnet IDs |
| <a name="output_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#output\_public\_subnet\_cidrs) | Public subnet CIDRs |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Public subnet IDs |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | VPC CIDR range |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Development

### Prerequisites

- [terraform](https://learn.hashicorp.com/terraform/getting-started/install#installing-terraform)
- [terraform-docs](https://github.com/segmentio/terraform-docs)
- [pre-commit](https://pre-commit.com/#install)
- [golang](https://golang.org/doc/install#install)
- [golint](https://github.com/golang/lint#installation)

### Configurations

- Configure pre-commit hooks
```sh
pre-commit install
```


- Configure golang deps for tests
```sh
> go get github.com/gruntwork-io/terratest/modules/terraform
> go get github.com/stretchr/testify/assert
```



### Tests

- Tests are available in `test` directory

- In the test directory, run the below command
```sh
go test
```



## Authors

This project is authored by below people

- SourceFuse
