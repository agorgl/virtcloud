terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.14"
    }
    null = {
      source = "hashicorp/null"
      version = "3.1.0"
    }
    ssh = {
      source = "loafoe/ssh"
      version = "1.2.0"
    }
  }
}

locals {
  user = "debian"
  lb_net = cidrsubnet(var.subnet, 4, 12)
  internal_dns_ip = cidrhost(local.lb_net, 1)
  control_plane_host = "${libvirt_domain.instance.name}.${var.domain}"
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
  addresses = [var.subnet]
  dns {
    enabled = true
    forwarders {
      domain = var.domain
      address = local.internal_dns_ip
    }
  }
  dnsmasq_options {
    options  {
      option_name = "listen-address"
      option_value = cidrhost(var.subnet, 1)
    }
  }
}

resource "libvirt_cloudinit_disk" "initdisk" {
  name      = "init"
  pool      = libvirt_pool.storage.name
  user_data = templatefile("${path.module}/config/cloud_init.cfg", {
                hostname = "instance",
                user = local.user,
                ssh_key = var.ssh_key,
                lb_net = local.lb_net,
                domain = var.domain
              })
}

resource "libvirt_domain" "instance" {
  name      = "instance"
  vcpu      = 1
  memory    = "2048"
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

resource "null_resource" provision_wait {
  triggers = {
    instance_ids = libvirt_domain.instance.id
  }

  connection {
    type     = "ssh"
    user     = local.user
    host     = local.control_plane_host
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait >/dev/null",
      "until [ -f /etc/rancher/k3s/k3s.yaml ]; do sleep 1; done",
    ]
  }
}

resource "ssh_resource" "kubeconfig" {
  depends_on = [
    null_resource.provision_wait,
  ]

  host         = local.control_plane_host
  user         = local.user
  agent        = true

  commands = [
    "sudo cat /etc/rancher/k3s/k3s.yaml",
  ]
}
