variable "cluster_name" {
  type        = string
  description = "The unique name that identifies the cluster"
}

variable "cluster_domain" {
  type        = string
  description = "The domain used by the cluster DNS server on the instance network"
}

variable "cluster_subnet" {
  type        = string
  description = "The subnet associated with the cluster instance network"
}

variable "cluster_ssh_key" {
  type        = string
  description = "The key used for accessing cluster instances using SSH"
}

variable "cluster_pool_dir" {
  type        = string
  description = "The directory that the cluster storage pool will keep its volumes"
}
