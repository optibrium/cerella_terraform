variable "name" {
  type        = string
  description = "The name of the workers."
}

variable "eks_cluster" {
  description = "The output `eks_cluster` of the eks cluster light module."

  type = object({
    name     = string
    endpoint = string
    version  = string
    ca_cert  = string
    oidc_provider = object({
      url             = string
      client_id_list  = list(string)
      thumbprint_list = list(string)
      arn             = string
    })
    region              = string
    aws_account         = string
    internal_dns_domain = string
  })
}

variable "security_group_ids" {
  type        = list(string)
  description = "The list of security group ID of the workers."
}

variable "eks_subnet_ids" {
  type        = list(string)
  description = "Subnet ids for the EKS cluster."
}

variable "datadog" {
  type        = bool
  default     = true
  description = "If the workers should be monitored by the Datadog AWS integration."
}

variable "cluster_autoscaler" {
  type        = bool
  default     = true
  description = "Wether the cluster autoscaler should be able to manage this set of nodes."
}

variable "tag_platform" {
  type        = string
  description = "The AWS tag 'Platform' to add to resources."
}

variable "tag_environment" {
  type        = string
  description = "The AWS tag 'Environment' to add to resources."
}

variable "tag_group" {
  type        = string
  description = "The AWS tag and Kubernetes label 'Group' to add to EC2 instances and Kubernetes nodes."
  default     = null
}

variable "default_iam_policies" {
  type        = list(string)
  description = "The default policy ARNs to attach to the EKS workers."
}

variable "types" {
  type = list(string)
}

variable "min" {
  type = number
}

variable "max" {
  type = number
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

variable "spot" {
  type = object({
    price                                    = string
    on_demand_base_capacity                  = number
    on_demand_percentage_above_base_capacity = number
    allocation_strategy                      = string
  })

  default = null
}

variable "node_taints" {
  type        = map(string)
  default     = {}
  description = "Taints to add to workers on startup."
}

variable "node_labels" {
  type        = map(string)
  default     = {}
  description = "Labels to add to workers on startup."
}

variable "off_hours_recurrence" {
  type    = string
  default = ""
}

variable "work_hours_recurrence" {
  type    = string
  default = ""
}

variable "extra_userdata" {
  type    = string
  default = ""
}

variable "gpu_enabled" {
  type    = bool
  default = false
}

variable "suspended_processes" {
  type    = list(string)
  default = []
}

variable "max_lifetime" {
  type        = number
  default     = 2
  description = "The maximum age in days that the instances in this ASG should have. 0 means no limit."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "The tags to apply to the resources."
}
