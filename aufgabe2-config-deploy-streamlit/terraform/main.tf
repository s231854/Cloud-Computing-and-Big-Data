terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
  required_version = ">= 1.3.0"
}

provider "openstack" {
  user_name   = var.os_user_name
  password    = var.os_password
  auth_url    = var.os_auth_url
  tenant_id   = var.os_tenant_id
  domain_name = var.os_domain_name
}

# -------- Variablen (bei Bedarf in terraform.tfvars setzen) --------
variable "os_user_name" {}
variable "os_password" { sensitive = true }
variable "os_auth_url" {}
variable "os_tenant_id" {}
variable "os_domain_name" { default = "Default" }

variable "image" { default = "Ubuntu 22.04" }
variable "flavor" { default = "cb1.large" }
variable "network" { default = "DHBW" }
variable "key_pair" { default = "corne_key" }

# Name des Floating-IP-Pools (häufig: "public", "public-net", "ext-net")
variable "fip_pool" { default = "public" }

# -------- Compute-Instanz --------
resource "openstack_compute_instance_v2" "app" {
  name        = "aufgabe2-app"
  image_name  = var.image
  flavor_name = var.flavor
  key_pair    = var.key_pair

  network {
    name = var.network
  }
}




