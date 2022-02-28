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
