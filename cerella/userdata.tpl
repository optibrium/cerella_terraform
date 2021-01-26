#!/bin/bash

set -o xtrace

# Apply to the controlplane to connect this node to the Kubernetes cluster
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.environment.endpoint}' --b64-cluster-ca '${aws_eks_cluster.environment.certificate_authority.0.data}' '${var.cluster-name}'
