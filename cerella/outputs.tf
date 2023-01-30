#
# @author GDev
# @date November 2021
#

output "how_to_get_kubectl" {
  value = <<OUTPUT
How to get Kubeconfig:
aws eks --region ${var.region} update-kubeconfig --name ${var.cluster-name} --profile <my_profile_used_by_terraform>
OUTPUT
}

output "service_account_yaml" {
  value = <<HERE
  apiVersion: v1
  kind: ServiceAccount
  metadata:
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/<iam_role_name>
    name: ${var.service-account-name}
    namespace: ${var.service-account-namespace}

HERE

}

output "worker_nodes_iam_role_arn" {
  description = "ARN of worker nodes IAM role"
  value       = try(aws_iam_role.worker_nodes.arn, "")
}

output "external_secret_iam_role_arn" {
  description = "ARN of external secret IAM role"
  value       = try(module.external_secret_iam_role.iam_role_arn, "")
}

output "ingest_irsa_iam_role_name" {
  description = "ARN of ingest IRSA IAM role"
  value       = try(module.ingest_irsa_iam_role.iam_role_name, "")
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster endpoint"
  value       = try(aws_eks_cluster.environment.endpoint, "")
}

output "eks_cluster_ca_certificate" {
  description = "EKS Cluster CA Cert"
  value       = try(base64decode(aws_eks_cluster.environment.certificate_authority.0.data), "")
}

output "eks_cluster_token" {
  description = "EKS Cluster Token"
  value       = try(data.aws_eks_cluster_auth.environment_auth.token, "")
}

output "ingest_user_password" {
  description = "Password for ingest username"
  value       = try(random_password.ingest_password[0].result, "")
}

