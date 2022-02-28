#
# @author GDev
# @date Feb 2022
#

variable "hosted-zone-id" {
  type = string
}

variable "domain" {
  type = string
}

# Normally this would be IP restricted,
variable "ingress-cidr" {
  type = list(string)
}

variable "cluster-name" {
  type = string
}
