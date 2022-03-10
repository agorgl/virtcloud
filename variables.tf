variable "pool_dir" {
  type        = string
  description = "The directory that the storage pool will keep its volumes"
}

variable "base_image" {
  type        = string
  description = "The base image used as a backing volume for all instances"
  default     = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
}

variable "domain" {
  type        = string
  description = "The domain used by the DNS server on the instance network"
}
