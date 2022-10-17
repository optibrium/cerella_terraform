locals {
  eks_bootstrap_userdata = <<USERDATA

# Node to Join the EKS cluster with the right Tags
/etc/eks/bootstrap.sh \
  ${var.eks_cluster.name} \
  --b64-cluster-ca ${base64encode(var.eks_cluster.ca_cert)} \
  --apiserver-endpoint ${var.eks_cluster.endpoint} \

USERDATA

  workers_userdata = <<USERDATA
#!/usr/bin/env bash

${local.eks_bootstrap_userdata}

USERDATA

}
