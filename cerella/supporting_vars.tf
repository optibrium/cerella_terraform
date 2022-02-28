#
# @author GDev
# @date November 2021
#

# This might be overridden
variable "eks-instance-type" {
  default = "t2.large"
  type    = string
}

# This might be overridden
variable "eks-instance-count" {
  default = 3
}

variable "ingress-version" {
  default = "0.11.3"
}

variable "prometheus-version" {
  default = "19.2.3"
}

variable "cluster-ingress-port" {
  default = "30443"
  type    = string
}

variable "region" {
  default = "eu-west-1"
  type    = string
}

variable "eks-version" {
  default = "1.20"
  type    = string
}

variable "eks-ami" {
  default = "ami-031de2a4db6a7880f"
  type    = string
}

variable "right-availability-zone" {
  default = "eu-west-1a"
  type    = string
}

variable "left-availability-zone" {
  default = "eu-west-1b"
  type    = string
}

variable "cidr" {
  default = "10.0.0.0/16"
  type    = string
}

variable "right-subnet-cidr" {
  default = "10.0.1.0/24"
  type    = string
}

variable "left-subnet-cidr" {
  default = "10.0.2.0/24"
  type    = string
}
