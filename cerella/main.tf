module "ingest_kms_key" {
  source = "./modules/kms"

  alias_name  = "${var.cluster-name}-ingest-key"
  description = "Key to encrypt and decrypt secrets"

}
module "ingest_iam_policy" {
  source        = "./modules/iam/iam-policy"
  create_policy = true
  description   = "IAM Policy for ingest service."
  name          = "ingest-policy"
  policy_statements = [
    {
      sid = "kmsAccess"

      effect    = "Allow"
      actions   = ["kms:Encrypt", "kms:Decrypt"]
      resources = [module.ingest_kms_key.key_arn]
    }
  ]
}
module "ingest_iam_role" {
  source                        = "./modules/iam/iam-role-for-irsa"
  create_role                   = true
  role_name                     = "ingest"
  provider_url                  = replace(flatten(concat(aws_eks_cluster.environment[*].identity[*].oidc.0.issuer, [""]))[0], "https://", "")
  role_policy_arns              = [module.ingest_iam_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.k8s_service_account_namespace}:${var.k8s_service_account_name}"]
}
