terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.14"
    }
  }
}

provider "libvirt" {}

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
}

resource "libvirt_network" "network" {
  name      = "network"
  domain    = var.domain
  addresses = ["10.3.0.0/24"]
  dns {
    enabled = true
  }
}

resource "libvirt_domain" "instance" {
  name      = "instance"
  vcpu      = 1
  memory    = "1024"

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
