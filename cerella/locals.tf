locals {
  oidc_provider_url = replace(flatten(concat(aws_eks_cluster.environment[*].identity[*].oidc.0.issuer, [""]))[0], "https://", "")
}