output "vcn_id" {
  description = "VCN OCID"
  value       = oci_core_vcn.main.id
}

output "public_subnet_id" {
  description = "Public subnet OCID"
  value       = oci_core_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet OCID"
  value       = oci_core_subnet.private.id
}

output "vcn_cidr" {
  description = "VCN CIDR block"
  value       = var.vcn_cidr
}

output "internet_gateway_id" {
  description = "Internet Gateway OCID"
  value       = oci_core_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "NAT Gateway OCID"
  value       = oci_core_nat_gateway.main.id
}