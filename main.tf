data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "cloudinit_config" "server" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/scripts/cloud-init.yaml", {
      domain                    = var.domain
      project_name              = var.project_name
      environment               = var.environment
      technitium_admin_password = var.technitium_admin_password
    })
  }
}

module "networking" {
  source = "./modules/networking"

  compartment_id      = var.compartment_id
  project_name        = var.project_name
  environment         = var.environment
  vcn_cidr            = var.vcn_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "compute" {
  source = "./modules/compute"

  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  project_name        = var.project_name
  environment         = var.environment
  subnet_id           = module.networking.public_subnet_id
  ssh_public_key      = var.ssh_public_key
  instance_shape      = var.instance_shape
  instance_ocpus      = var.instance_ocpus
  instance_memory_gb  = var.instance_memory_gb
  boot_volume_size_gb = var.boot_volume_size_gb
  data_volume_size_gb = var.data_volume_size_gb
  user_data           = data.cloudinit_config.server.rendered
  assign_public_ip    = false
}

module "dns" {
  source = "git::https://github.com/eirian-j/DNSaC.git//modules/project-dns?ref=main"
  count  = var.cloudflare_api_token != "" ? 1 : 0

  providers = {
    cloudflare = cloudflare
  }

  project_name = var.project_name
  environment  = var.environment
  domain       = var.domain

  dns_records = {
    "${var.project_name}" = {
      type  = "A"
      value = module.compute.public_ip
      ttl   = 300
    }
    "dns-${var.project_name}" = {
      type  = "A"
      value = module.compute.public_ip
      ttl   = 300
    }
    "*.${var.project_name}" = {
      type  = "CNAME"
      value = "${var.project_name}.${var.domain}"
      ttl   = 300
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