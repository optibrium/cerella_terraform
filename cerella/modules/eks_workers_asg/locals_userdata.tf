locals {
  eks_bootstrap_userdata = <<USERDATA

# Node to Join the EKS cluster with the right Tags
/etc/eks/bootstrap.sh \
  --apiserver-endpoint '${var.eks_cluster_endpoint}'
  --b64-cluster-ca '${var.eks_cluster_ca_cert}' \
  '${var.cluster_name}'

USERDATA

  workers_userdata = <<USERDATA
#!/bin/bash

${local.eks_bootstrap_userdata}

USERDATA

}
