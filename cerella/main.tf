module "external_secret_iam_policy" {
  source        = "./modules/iam/iam-policy"
  create_policy = true
  description   = "IAM Policy for external secrets."
  name_prefix = "external-secret-"
  policy_statements = [
    {
      sid = "SecretManagerAccess"

      effect    = "Allow"
      actions   = [
        "sts:AssumeRoleWithWebIdentity",
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
        ]
      resources = [module.ingest_kms_key.key_arn]
    }
  ]
}

module "external_secret_iam_role" {
  source                        = "./modules/iam/iam-role-for-irsa"
  create_role                   = true
  role_name                     = "external-secret-${var.cluster-name}"
  provider_url                  = local.oidc_provider_url
  role_policy_arns              = [module.external_secret_iam_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.external_secret_service_account_namespace}:${var.external_secret_service_account_name}"]
}

module "ingest_kms_key" {
  source = "./modules/kms"

  alias_name  = "${var.cluster-name}-ingest-key"
  description = "Key to encrypt and decrypt secrets"

}
module "ingest_iam_policy" {
  source        = "./modules/iam/iam-policy"
  create_policy = true
  description   = "IAM Policy for ingest service."
  name_prefix          = "ingest-policy-"
  policy_statements = [
    {
      sid = "kmsAccess"

      effect    = "Allow"
      actions   = [
        "kms:Encrypt",
        "kms:Decrypt"
        ]
      resources = [module.ingest_kms_key.key_arn]
    }
  ]
}
module "ingest_irsa_iam_role" {
  source                        = "./modules/iam/iam-role-for-irsa"
  create_role                   = true
  role_name                     = "ingest-${var.cluster-name}"
  provider_url                  = local.oidc_provider_url
  role_policy_arns              = [module.ingest_iam_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.ingest_service_account_namespace}:${var.ingest_service_account_name}"]
}
