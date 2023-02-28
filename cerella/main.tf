module "external_secret_iam_policy" {
  source        = "./modules/iam/iam-policy"
  create_policy = true
  description   = "IAM Policy for external secrets."
  name_prefix   = "external-secret-"
  policy_statements = [
    {
      sid = "SecretManagerAccess"

      effect = "Allow"
      actions = [
        "sts:AssumeRoleWithWebIdentity",
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ]
      resources = [
        "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:CERELLA_*"
      ]
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
  name_prefix   = "ingest-policy-"
  policy_statements = [
    {
      sid = "kmsAccess"

      effect = "Allow"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt"
      ]
      resources = [
        module.ingest_kms_key.key_arn
      ]
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

module "cloudwatch_logs_iam_policy" {
  source        = "./modules/iam/iam-policy"
  create_policy = true
  description   = "IAM Policy for CloudWatch Agent."
  name_prefix   = "cloudwatch-agent-"
  policy_statements = [
    {
      sid = "CloudWatchAccess"

      effect = "Allow"
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ]
      resources = [
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
}

module "cloudwatch_logs_iam_role" {
  source                        = "./modules/iam/iam-role-for-irsa"
  create_role                   = true
  role_name                     = "cloudwatch-agent-${var.cluster-name}"
  provider_url                  = local.oidc_provider_url
  role_policy_arns              = [module.cloudwatch_logs_iam_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-for-fluent-bit"]
}
