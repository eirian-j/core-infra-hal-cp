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

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ubuntu.images[0].id
    boot_volume_size_in_gbs = var.boot_volume_size_gb
  }

  create_vnic_details {
    subnet_id                 = var.subnet_id
    display_name              = "${var.project_name}-${var.environment}-vnic"
    assign_public_ip          = true
    skip_source_dest_check    = false
    hostname_label            = "${var.project_name}-${var.environment}"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    # Remove user_data temporarily to isolate the issue
  }

  freeform_tags = local.common_tags

  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }
}

# Data volume removed - using single 50GB boot volume instead

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

