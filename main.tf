terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.14"
    }
  }
}

provider "libvirt" {}

locals {
  subnet = "10.3.0.0/24"
  lb_net = cidrsubnet(local.subnet, 4, 12)
  ingress_ip = cidrhost(local.lb_net, 0)
}

resource "libvirt_pool" "storage" {
  name = "storage"
  type = "dir"
  path = var.pool_dir
}

resource "libvirt_volume" "image" {
  name   = "image"
  pool   = libvirt_pool.storage.name
  source = var.base_image
}

resource "libvirt_volume" "disk" {
  name           = "disk"
  pool           = libvirt_pool.storage.name
  base_volume_id = libvirt_volume.image.id
  size           = 1024 * 1024 * 1024 * 8
}

resource "libvirt_network" "network" {
  name      = "network"
  domain    = var.domain
  addresses = [local.subnet]
  dns {
    enabled = true
  }
  dnsmasq_options {
    options  {
      option_name = "listen-address"
      option_value = cidrhost(local.subnet, 1)
    }
  }
}

resource "libvirt_cloudinit_disk" "initdisk" {
  name      = "init"
  pool      = libvirt_pool.storage.name
  user_data = templatefile("${path.module}/config/cloud_init.cfg", {
                ssh_key = var.ssh_key,
                lb_net = local.lb_net
              })
}

resource "libvirt_domain" "instance" {
  name      = "instance"
  vcpu      = 1
  memory    = "1024"
  cloudinit = libvirt_cloudinit_disk.initdisk.id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  network_interface {
    network_id     = libvirt_network.network.id
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.disk.id
  }
}
