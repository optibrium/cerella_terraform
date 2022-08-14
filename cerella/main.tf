module "ingest_iam_policy" {
  source        = "./modules/iam/iam-policy"
  create_policy = true
  description   = "IAM Policy for ingest service."
  name = "ingest-policy"
  policy_statements = [
    {
      sid = "kmsAccess"

      effect    = "Allow"
      actions   = ["kms:Encrypt", "kms:Decrypt"]
      resources = ["arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab", "arn:aws:kms:us-west-2:111122223333:key/0987dcba-09fe-87dc-65ba-ab0987654321"]
    }
  ]
}
module "ingest_iam_role" {
  source       = "./modules/iam/iam-role-for-irsa"
  create_role  = true
  role_name    = "ingest"
  provider_url = replace(flatten(concat(aws_eks_cluster.environment[*].identity[*].oidc.0.issuer, [""]))[0], "https://", "")
  #   role_policy_arns              = [aws_iam_policy.ingest.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.k8s_service_account_namespace}:${var.k8s_service_account_name}"]
}
