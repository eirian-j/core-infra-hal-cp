variable "compartment_id" {
  description = "OCI compartment OCID"
  type        = string
}

variable "availability_domain" {
  description = "Availability domain for the instance"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet OCID for the instance"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
}

variable "instance_shape" {
  description = "OCI instance shape"
  type        = string
}

variable "instance_ocpus" {
  description = "Number of OCPUs"
  type        = number
}

variable "instance_memory_gb" {
  description = "Memory in GB"
  type        = number
}

variable "boot_volume_size_gb" {
  description = "Boot volume size in GB"
  type        = number
}

variable "user_data" {
  description = "Cloud-init user data"
  type        = string
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP"
  type        = bool
  default     = true
}

variable "assign_ipv6" {
  description = "Whether to assign IPv6 address"
  type        = bool
  default     = false
}