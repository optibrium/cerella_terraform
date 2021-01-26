#
# @author GDev
# @date November 2020
#

terraform {
  backend "s3" {
    bucket  = "<Your S3 terraform backend bucket>"
    key     = "terraform/cerella.tfstate"
    profile = "<Your AWS profile name>"
    region  = "eu-west-1"
  }
}

provider "aws" {
  profile = "demo"
  region  = "eu-west-1"
}

module "cerella" {

  source             = "./cerella"
  hosted-zone-id     = "<Your Hosted Zone ID>"
  domain             = "<Your DNS domain>"
  eks-instance-type  = "<Please contact support>"
  eks-instance-count = "<Please contact support>"
  s3-bucket-id       = "<Your Datasource Bucket ID>"
  ingress_cidr       = ["<The client source CIDR>"]
}

output "config_map_aws_auth" {
  value = module.cerella.config_map_aws_auth
}
