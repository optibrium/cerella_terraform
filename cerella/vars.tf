#
# @author GDev
# @date November 2020
#

variable "ingress_cidr" {
  type = list(string)
}

variable "hosted-zone-id" {
  type = string
}

variable "s3-bucket-id" {
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

variable "eks-ami" {
  default = "ami-098fb7e9b507904e7"
  type    = string
}

variable "eks-instance-type" {
  default = "t2.large"
  type    = string
}

variable "eks-instance-count" {
  default = 3
}

variable "db-instance-count" {
  default = 1
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
