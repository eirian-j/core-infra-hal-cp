variable "compartment_id" {
  description = "OCI compartment OCID"
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

variable "vcn_cidr" {
  description = "CIDR block for VCN"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
}

variable "enable_ipv6" {
  description = "Enable IPv6 for VCN"
  type        = bool
  default     = false
}