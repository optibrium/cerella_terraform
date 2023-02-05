terraform {
  backend "s3" {
    bucket  = "optibrium-devops"
    key     = "terraform/sandbox.cerella.ai.tfstate"
    profile = "root"
    region  = "eu-west-2"
  }
}

provider "aws" {
  profile = "sandbox"
  region  = "eu-west-1"
}

provider "kubernetes" {
  host                   = module.cerella.eks_cluster_endpoint
  cluster_ca_certificate = module.cerella.eks_cluster_ca_certificate
  token                  = module.cerella.eks_cluster_token
}

module "cerella" {

  # source                           = "git::https://github.com/optibrium/cerella_terraform.git//cerella?ref=v1.5.6"
  source                           = "./cerella"
  hosted-zone-id                   = "Z017943613E9OOX5CNU9"
  domain                           = "sandbox.cerella.ai"
  cluster-name                     = "sandbox"
  eks-instance-type                = "t2.large"
  eks-instance-count               = "5"
  ingress-cidr                     = ["185.62.156.206/32"]
  ingest-instance-type             = "t3.2xlarge"
  vpc_id                           = "vpc-01baf4ed51c746d9d"
  private_subnet_ids               = ["subnet-03822489e225e9062", "subnet-08b159b81cb93e0dd", "subnet-05210cafdb7636d21"]
  public_subnet_ids                = ["subnet-03822489e225e9062", "subnet-08b159b81cb93e0dd", "subnet-05210cafdb7636d21"]
  create_secretsmanager            = "true"
  region                           = "eu-west-1"
  intellegens_intermediate_licence = <<EOL
  {"e": "2027-07-14T23:59:59Z","k": "4aeb56dc0f634c32b3fdf325f1cea7a2cf2519a3596c4e79a614ce69c2f877ad","p": ["mltools","modelserver"],"s": "M1b8mVX6jdGtFRhFhj/4djKTSsTePVu0TsJDzjz6vYn8uba2OJsg0H0E/d18h9aw97vWyhjSQ9Xzl0CSy1nECQ==","t": "i","u": "optibrium","v": 1,"w": 30},
EOL
  intellegens_licence              = <<EOL
  {"e": "2025-12-31T23:59:59Z","k": "","p": ["mltools","modelserver"],"s": "yS3a6ifsFg9L8zDAoiqOOAwmCoZBLotHI9qP9nDFepAq4F9ue0viYM6t1pH4f0IapxBezLS0b/YJdPr3fBgYBQ==","t": "e","u": "Optibrium Testing","v": 1,"w": 30}
EOL
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

output "ingest_user_password" {
  value = module.cerella.ingest_user_password
  sensitive = true
}

output "ingest_user_name" {
  value = "ingest"
  sensitive = true
}

output "eks_cluster_name" {
  value = module.cerella.eks_cluster_name
}
