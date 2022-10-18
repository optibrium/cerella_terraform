variable "eks_version" {
  default = "1.22"
  type    = string
}

variable "min" {
  type    = number
  default = 0
}

variable "max" {
  type    = number
  default = 2
}

variable "cluster_name" {
  type = string
}

variable "eks_subnet_ids" {
  type        = list(string)
  description = "Subnet ids for the EKS cluster."
}

variable "max_lifetime" {
  type        = number
  default     = 2
  description = "The maximum age in days that the instances in this ASG should have. 0 means no limit."
}

variable "node_taints" {
  type        = map(string)
  default     = {}
  description = "Taints to add to workers on startup."
}

variable "security_group_ids" {
  type        = list(string)
  description = "The list of security group ID of the workers."
}

variable "eks_cluster_ca_cert" {
  type = string
}

variable "eks_cluster_endpoint" {
  type = string
}

variable "eks_cluster_region" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "disk_size" {
  type = number
}

variable "disk_type" {
  type    = string
  default = "gp2"
}

variable "disk_iops" {
  type    = number
  default = 0
}

variable "apply_taints" {
  type        = bool
  default     = false
  description = "Wether to apply taints on node or not."
}

variable "node_labels" {
  type        = map(string)
  default     = {}
  description = "Labels to add to workers on startup."
}

variable "worker_iam_instance_profile" {
  type    = string
}