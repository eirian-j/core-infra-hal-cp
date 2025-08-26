data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "cloudinit_config" "server" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/scripts/cloud-init.yaml", {
      DOMAIN                    = var.domain
      PROJECT_NAME              = var.project_name
      ENVIRONMENT               = var.environment
      TECHNITIUM_ADMIN_PASSWORD = var.technitium_admin_password
      GRAFANA_LOKI_URL          = var.grafana_loki_url
      GRAFANA_LOKI_USERNAME     = var.grafana_loki_username
      GRAFANA_LOKI_PASSWORD     = var.grafana_loki_password
      domain                    = var.domain
      project_name              = var.project_name
      environment               = var.environment
      technitium_admin_password = var.technitium_admin_password
    })
  }
}

module "networking" {
  source = "./modules/networking"

  providers = {
    oci = oci
  }

  compartment_id      = var.compartment_id
  project_name        = var.project_name
  environment         = var.environment
  vcn_cidr            = var.vcn_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "compute" {
  source = "./modules/compute"

  providers = {
    oci = oci
  }

  compartment_id      = var.compartment_id
  # Use the actual AD name from data source
  # Automatically try next AD if capacity issues
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain_number].name
  project_name        = var.project_name
  environment         = var.environment
  subnet_id           = module.networking.public_subnet_id
  ssh_public_key      = var.ssh_public_key
  instance_shape      = var.instance_shape
  instance_ocpus      = var.instance_ocpus
  instance_memory_gb  = var.instance_memory_gb
  boot_volume_size_gb = var.boot_volume_size_gb
  user_data           = data.cloudinit_config.server.rendered
  assign_public_ip    = false
}

module "dns" {
  source = "git::https://github.com/eirian-j/DNSaC.git//modules/project-dns?ref=main"
  count  = var.cloudflare_api_token != "" && var.cloudflare_zone_id != "" ? 1 : 0

  providers = {
    cloudflare = cloudflare
  }

  zone_id = var.cloudflare_zone_id
  domain  = var.domain
  project = "hal"  # Must be one of: monika, jarvis, hal

  services = {
    "control" = {
      environments = {
        "${var.environment}" = {
          a_records = [
            {
              ip_address = module.compute.public_ip
              ttl        = 300
              comment    = "HAL Control Plane - ${var.environment}"
            }
          ]
          cname_target  = "control-${var.environment}.hal.${var.domain}"
          cname_ttl     = 300
          cname_comment = "Wildcard for HAL control services"
        }
      }
    }
    "dns" = {
      environments = {
        "${var.environment}" = {
          a_records = [
            {
              ip_address = module.compute.public_ip
              ttl        = 300
              comment    = "Technitium DNS Server - ${var.environment}"
            }
          ]
        }
      }
    }
  }
}


resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.yml.tpl", {
    instance_name = "${var.project_name}-control"
    public_ip     = module.compute.public_ip
    private_ip    = module.compute.private_ip
    project_name  = var.project_name
    environment   = var.environment
    domain        = var.domain
  })
  filename = "${path.module}/ansible/inventory.yml"
}

resource "local_file" "ssh_config" {
  content = templatefile("${path.module}/templates/ssh_config.tpl", {
    instance_name = "${var.project_name}-control"
    public_ip     = module.compute.public_ip
    project_name  = var.project_name
  })
  filename = "${path.module}/ssh_config"
}