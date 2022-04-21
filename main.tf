module "cluster" {
  source = "./modules/cluster"

  name     = var.cluster_name
  domain   = var.cluster_domain
  ssh_key  = var.cluster_ssh_key
  pool_dir = var.cluster_pool_dir
}
