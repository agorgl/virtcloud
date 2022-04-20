output "instance_ip" {
  value = try(libvirt_domain.instance.network_interface[0].addresses[0], "")
}

output "kubeconfig" {
  value       = replace(ssh_resource.kubeconfig.result, "127.0.0.1", "${local.control_plane_host}")
  sensitive   = true
}
