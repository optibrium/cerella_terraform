terraform {
  backend "s3" {
    bucket  = "<Your S3 terraform backend bucket>"
    key     = "terraform/cerella.tfstate"
    profile = "<Your AWS profile name>"
    region  = "eu-west-1"
  }
}

provider "aws" {
  profile = "<Your AWS profile name>"
  region  = "eu-west-1"
}

provider "kubernetes" {
  host                   = module.cerella.eks_cluster_endpoint
  cluster_ca_certificate = module.cerella.eks_cluster_ca_certificate
  token                  = module.cerella.eks_cluster_token
}

module "cerella" {

  source               = "git::https://github.com/optibrium/cerella_terraform.git//cerella?ref=v1.2.2"
  hosted-zone-id       = "<Your Hosted Zone ID>"
  domain               = "<Your DNS domain>"
  cluster-name         = "<Please contact support>"
  eks-instance-type    = "<Please contact support>"
  eks-instance-count   = "<Please contact support>"
  ingress_cidr         = ["<The client source CIDR>"]
  ingest-instance-type = "t3.2xlarge"
  registry_username    = var.registry_username
  registry_password    = var.registry_password
}

variable "registry_username" {
  type = string
}

variable "registry_password" {
  type = string
}

output "how_to_get_kubectl" {
  value = module.cerella.how_to_get_kubectl
}
