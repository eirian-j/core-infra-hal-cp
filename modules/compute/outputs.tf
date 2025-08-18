output "instance_id" {
  description = "Instance OCID"
  value       = oci_core_instance.main.id
}

output "private_ip" {
  description = "Instance private IP"
  value       = oci_core_instance.main.private_ip
}

output "public_ip" {
  description = "Instance public IP"
  value       = oci_core_public_ip.reserved.ip_address
}

output "reserved_public_ip_id" {
  description = "Reserved public IP OCID"
  value       = oci_core_public_ip.reserved.id
}

output "data_volume_id" {
  description = "Data volume OCID"
  value       = oci_core_volume.data.id
}

output "instance_name" {
  description = "Instance display name"
  value       = oci_core_instance.main.display_name
}