locals {
  // The following locals map a private subnet to respective public subnet,
  // and if nat_gateway_enabled is true then this is used to update
  // routes to public internet in the respective private subnet in the following local.
  // If it is not true then it takes the value from the variable az_ngw_ids
  // and maps it to the private subnet. If even that is empty,
  // then no routes to public internet are added.
  public_internet_mapping = { for x in var.private_subnets : x.name => replace(x.name, "-private-", "-public-") if var.nat_gateway_enabled == true }

  subnet_ngw_ids = { for x in var.private_subnets : x.name => var.nat_gateway_enabled == true ? aws_nat_gateway.public[local.public_internet_mapping[x.name]].id : lookup(var.az_ngw_ids, x.availability_zone, null) }
}
