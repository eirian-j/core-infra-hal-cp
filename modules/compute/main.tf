locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

data "oci_core_images" "ubuntu" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "main" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  display_name        = "${var.project_name}-${var.environment}-control"
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_gb
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ubuntu.images[0].id
    boot_volume_size_in_gbs = var.boot_volume_size_gb
  }

  create_vnic_details {
    subnet_id                 = var.subnet_id
    display_name              = "${var.project_name}-${var.environment}-vnic"
    assign_public_ip          = var.assign_public_ip
    assign_ipv6ip             = var.assign_ipv6
    skip_source_dest_check    = false
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = var.user_data
  }

  agent_config {
    is_monitoring_disabled  = false
    is_management_disabled  = false
    are_all_plugins_disabled = false
    
    plugins_config {
      name          = "Vulnerability Scanning"
      desired_state = "DISABLED"
    }
    
    plugins_config {
      name          = "Compute Instance Monitoring"
      desired_state = "ENABLED"
    }
    
    plugins_config {
      name          = "Bastion"
      desired_state = "DISABLED"
    }
  }

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }
}

resource "oci_core_volume" "data" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  display_name        = "${var.project_name}-${var.environment}-data"
  size_in_gbs         = var.data_volume_size_gb
  vpus_per_gb         = 10  # 10 VPUs per GB for balanced performance

  freeform_tags = local.common_tags
}

resource "oci_core_volume_attachment" "data" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.main.id
  volume_id       = oci_core_volume.data.id
  display_name    = "${var.project_name}-${var.environment}-data-attachment"
  device          = "/dev/oracleoci/oraclevdb"
}

resource "oci_core_public_ip" "reserved" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-${var.environment}-reserved-ip"
  lifetime       = "RESERVED"

  freeform_tags = local.common_tags
}

data "oci_core_vnic_attachments" "main" {
  compartment_id = var.compartment_id
  instance_id    = oci_core_instance.main.id
}

data "oci_core_vnic" "main" {
  vnic_id = data.oci_core_vnic_attachments.main.vnic_attachments[0].vnic_id
}

data "oci_core_private_ips" "main" {
  vnic_id = data.oci_core_vnic.main.id
}

# Use Terraform native resource instead of OCI CLI
resource "oci_core_public_ip" "assigned" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-${var.environment}-assigned-ip"
  lifetime       = "EPHEMERAL"
  private_ip_id  = data.oci_core_private_ips.main.private_ips[0].id

  freeform_tags = local.common_tags
  
  depends_on = [
    oci_core_instance.main,
    data.oci_core_private_ips.main
  ]
}