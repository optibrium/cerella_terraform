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
      eks.amazonaws.com/role-arn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.irsa.name}
    name: ${var.service_account_name}
    namespace: ${var.namespace}

HERE

}

output "iam_role" {
  value = {
    name = aws_iam_role.irsa.name
    arn  = aws_iam_role.irsa.arn
  }
}