terraform {
  backend "s3" {
    bucket  = "<Your S3 terraform backend bucket>"
    key     = "terraform/cerella.tfstate"
    profile = "<Your AWS profile name>"
    region  = "<AWS region>"
  }
}

provider "aws" {
  profile = "<Your AWS profile name>"
  region  = "<AWS region>"
}

provider "kubernetes" {
  host                   = module.cerella.eks_cluster_endpoint
  cluster_ca_certificate = module.cerella.eks_cluster_ca_certificate
  token                  = module.cerella.eks_cluster_token
}

module "cerella" {

  source                           = "git::https://github.com/optibrium/cerella_terraform.git//cerella?ref=v1.5.9"
  hosted-zone-id                   = "<Your R53 Hosted Zone ID>"
  domain                           = "<Your DNS domain>"
  cluster-name                     = "<EKS Cluster name>"
  eks-instance-type                = "t3.large"
  eks-instance-count               = "4"
  ingress-cidr                     = ["Client source CIDR"]
  ingest-instance-type             = "t3.2xlarge"
  vpc_id                           = "<Your VPC ID>"
  private_subnet_ids               = ["List of private subnet ids"]
  public_subnet_ids                = ["List of public subnet ids"] # If there are no public subnets then use private cidr here
  create_secretsmanager            = "true"
  region                           = "<AWS region>"
  intellegens_intermediate_licence = ""
  intellegens_licence              = ""
  acm-certificate-arn              = "<SSl Cert ARN>"
}

output "how_to_get_kubectl" {
  value = module.cerella.how_to_get_kubectl
}

output "worker_nodes_iam_role_arn" {
  value = module.cerella.worker_nodes_iam_role_arn
}

output "external_secret_iam_role_arn" {
  value = module.cerella.external_secret_iam_role_arn
}

output "ingest_irsa_iam_role_name" {
  value = module.cerella.ingest_irsa_iam_role_name
}