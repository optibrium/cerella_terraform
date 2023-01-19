locals {
  oidc_provider_url  = replace(flatten(concat(aws_eks_cluster.environment[*].identity[*].oidc.0.issuer, [""]))[0], "https://", "")
  create_vpc         = var.vpc_id == ""
  private_subnet_ids = local.create_vpc ? [aws_subnet.right[0].id, aws_subnet.left[0].id] : var.private_subnet_ids
  public_subnet_ids  = local.create_vpc ? [aws_subnet.right[0].id, aws_subnet.left[0].id] : var.public_subnet_ids
  vpc_id             = local.create_vpc ? aws_vpc.environment[0].id : var.vpc_id
}
