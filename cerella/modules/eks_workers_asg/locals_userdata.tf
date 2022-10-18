locals {
  node_taints = join(",", [for key, value in var.node_taints : "${key}=${value}"])
  node_labels = join(",", [for key, value in var.node_labels : "${key}=${value}"])

  eks_bootstrap_userdata = <<USERDATA

INSTANCE_ID=$(curl -sS http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')

# Get Group tag
GROUP_TAG=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Group"  --region=$REGION --query 'Tags[].Value' --output text)

KUBELET_EXTRA_ARGS="--node-labels=Group=$GROUP_TAG"

# Add Taints to node registration if set in the right EC2 Tag
if [[ -n "${local.node_taints}" ]]
 then
  KUBELET_EXTRA_ARGS="$KUBELET_EXTRA_ARGS  --register-with-taints=${local.node_taints}"
fi

# Add Label to node registration if set in the right EC2 Tag
if [[ -n "${local.node_labels}" ]]
 then
  KUBELET_EXTRA_ARGS="$KUBELET_EXTRA_ARGS  --node-labels=${local.node_labels}"
fi


# Node to Join the EKS cluster with the right Tags
/etc/eks/bootstrap.sh \
  --apiserver-endpoint '${var.eks_cluster_endpoint}' \
  --b64-cluster-ca '${var.eks_cluster_ca_cert}' \
  '${var.cluster_name}' \
  --kubelet-extra-args "$KUBELET_EXTRA_ARGS"

USERDATA

  workers_userdata = <<USERDATA
#!/bin/bash

${local.eks_bootstrap_userdata}

USERDATA

}
