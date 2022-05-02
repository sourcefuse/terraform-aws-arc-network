region         = "us-east-1"
environment    = "dev"
profile        = "sf_ref_arch"
vpc_cidr_block = "15.0.0.0/16"
availability_zones = [
  "us-east-1a",
  "us-east-1b"
]
tags = {
  Environment = "dev"
  ENV         = "dev"
  Project     = "sf-ref-arch"
  Creator     = "terraform"
}

stage            = "dev"
name             = "ec2-bastion"
instance_type    = "t3a.nano"
ssh_key_path     = "./secrets"
generate_ssh_key = true
user_data = [
  "yum install -y postgresql-client-common"
]
security_groups               = []
root_block_device_encrypted   = true
metadata_http_tokens_required = true
associate_public_ip_address   = true
