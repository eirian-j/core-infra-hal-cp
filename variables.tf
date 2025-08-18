variable "region" {
  description = "OCI region"
  type        = string
  default     = "ap-singapore-1"
}

variable "compartment_id" {
  description = "OCI compartment OCID"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "hal"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "domain" {
  description = "Domain name"
  type        = string
  default     = "eirian.io"
}

variable "availability_domain" {
  description = "Availability domain for resources"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
}

variable "instance_shape" {
  description = "OCI instance shape"
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "instance_ocpus" {
  description = "Number of OCPUs"
  type        = number
  default     = 1
}

variable "instance_memory_gb" {
  description = "Memory in GB"
  type        = number
  default     = 1
}

variable "boot_volume_size_gb" {
  description = "Boot volume size in GB"
  type        = number
  default     = 30
}

variable "data_volume_size_gb" {
  description = "Data volume size in GB"
  type        = number
  default     = 20
}

variable "vcn_cidr" {
  description = "CIDR block for VCN"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/28"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.1.16/28"
}

variable "technitium_admin_password" {
  description = "Technitium DNS admin password"
  type        = string
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token for DNS management"
  type        = string
  sensitive   = true
  default     = ""
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID"
  type        = string
  default     = ""
}