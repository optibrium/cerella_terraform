#
# @author GDev
# @date November 2020
#

variable "cerella_version" {
  # TODO: Change with v1
  default = "0.8.15"
}

variable "docker_config" {
  type      = string
  sensitive = true
}

variable "ingress_cidr" {
  type = list(string)
}

variable "hosted-zone-id" {
  type = string
}

variable "domain" {
  type = string
}

variable "cluster-name" {
  default = "cerella"
  type    = string
}

variable "cluster-ingress-port" {
  default = "30080"
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

variable "eks-instance-type" {
  default = "t2.large"
  type    = string
}

variable "eks-instance-count" {
  default = 3
}

variable "right_availability_zone" {
  default = "eu-west-1a"
  type    = string
}

variable "left_availability_zone" {
  default = "eu-west-1b"
  type    = string
}

variable "cidr" {
  default = "10.0.0.0/16"
  type    = string
}

variable "right_subnet_cidr" {
  default = "10.0.1.0/24"
  type    = string
}

variable "left_subnet_cidr" {
  default = "10.0.2.0/24"
  type    = string
}
