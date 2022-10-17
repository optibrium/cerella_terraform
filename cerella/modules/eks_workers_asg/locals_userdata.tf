locals {
  eks_bootstrap_userdata = <<USERDATA

# Node to Join the EKS cluster with the right Tags
/etc/eks/bootstrap.sh \
  ${var.cluster_name} \
  --b64-cluster-ca ${var.eks_cluster_ca_cert} \
  --apiserver-endpoint ${var.eks_cluster_endpoint} \

USERDATA

  workers_userdata = <<USERDATA
#!/usr/bin/env bash

${local.eks_bootstrap_userdata}

USERDATA

}
