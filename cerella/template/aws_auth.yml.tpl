- rolearn: ${aws_iam_role.worker_nodes.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- userarn: ${aws_iam_user.optibrium.arn}
  username: kubectl-access-user
  groups:
    - system:masters
