locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.worker_nodes.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

output "config_map_aws_auth" {
  value = local.config_map_aws_auth
}

output "how-to-getkubeconfig" {
  value = "aws eks --region ${var.region} update-kubeconfig --name ${var.cluster-name} --profile <my_profile>"
}
