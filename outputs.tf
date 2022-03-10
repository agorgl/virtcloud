output "instance_ip" {
  value = try(libvirt_domain.instance.network_interface[0].addresses[0], "")
}
