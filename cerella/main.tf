module "ingest_iam_policy" {
    source = "./modules/iam/iam-policy"
    create_policy = true
    description = "IAM Policy for ingest service."
    policy = "${file("iam_policies/ingest_policy.tpl")}"
}
module "ingest_iam_role" {
  source                        = "./modules/iam/iam-role-for-irsa"
  create_role                   = true
  role_name                     = "ingest"
  provider_url                  = replace(flatten(concat(aws_eks_cluster.environment[*].identity[*].oidc.0.issuer, [""]))[0], "https://", "")
#   role_policy_arns              = [aws_iam_policy.ingest.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.k8s_service_account_namespace}:${var.k8s_service_account_name}"]
}
