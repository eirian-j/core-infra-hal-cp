output "instance_public_ip" {
  description = "Public IP address of the control plane instance"
  value       = module.compute.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the control plane instance"
  value       = module.compute.private_ip
}

output "instance_id" {
  description = "OCID of the control plane instance"
  value       = module.compute.instance_id
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${module.compute.public_ip}"
}

output "technitium_url" {
  description = "Technitium DNS Server Web UI URL"
  value       = "http://${module.compute.public_ip}:5380"
}

output "dns_server" {
  description = "DNS server address"
  value       = module.compute.public_ip
}

output "vcn_id" {
  description = "VCN OCID"
  value       = module.networking.vcn_id
}

output "public_subnet_id" {
  description = "Public subnet OCID"
  value       = module.networking.public_subnet_id
}

output "private_subnet_id" {
  description = "Private subnet OCID"
  value       = module.networking.private_subnet_id
}

output "data_volume_id" {
  description = "Data volume OCID"
  value       = module.compute.data_volume_id
}

output "project_info" {
  description = "Project information"
  value = {
    project_name = var.project_name
    environment  = var.environment
    domain       = var.domain
    region       = var.region
  }
}