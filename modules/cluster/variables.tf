variable "name" {
  type        = string
  description = "The unique name that identifies this cluster"
}

variable "domain" {
  type        = string
  description = "The domain used by the DNS server on the instance network"
}

variable "subnet" {
  type        = string
  description = "The subnet associated with the instance network"
}

variable "ssh_key" {
  type        = string
  description = "The key used for accessing instances using SSH"
}

variable "pool_dir" {
  type        = string
  description = "The directory that the storage pool will keep its volumes"
}

variable "base_image" {
  type        = string
  description = "The base image used as a backing volume for all instances"
  default     = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
}
