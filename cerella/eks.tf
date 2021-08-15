#
# @author GDev
# @date November 2020
#

resource "aws_eks_cluster" "environment" {
  name     = var.cluster-name
  role_arn = aws_iam_role.control_plane.arn
  version  = var.eks-version

  vpc_config {
    security_group_ids = [aws_security_group.control_plane.id]
    subnet_ids         = [aws_subnet.right.id, aws_subnet.left.id]
  }
}

resource "aws_launch_configuration" "workers" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.worker_nodes.name
  image_id                    = var.eks-ami
  instance_type               = var.eks-instance-type
  key_name                    = "optibrium"
  name_prefix                 = "eks_workers"
  security_groups             = [aws_security_group.worker_nodes.id]
  user_data                   = local.eks_worker_userdata

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_size = 100
  }
}

resource "aws_autoscaling_group" "workers" {

  desired_capacity          = var.eks-instance-count
  health_check_grace_period = 300
  launch_configuration      = aws_launch_configuration.workers.id
  max_size                  = 7
  min_size                  = 3
  name                      = "worker_nodes"
  vpc_zone_identifier       = [aws_subnet.left.id, aws_subnet.right.id]

  tag {
    key                 = "Name"
    value               = var.cluster-name
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }
}

data "aws_eks_cluster_auth" "environment_auth" {
  name = var.cluster-name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.environment.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.environment.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.environment_auth.token
}

resource "kubernetes_config_map" "aws_auth_configmap" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<AUTH
- rolearn: ${aws_iam_role.worker_nodes.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- userarn: ${aws_iam_user.optibrium.arn}
  username: kubectl-access-user
  groups:
    - system:masters
AUTH
  }
}

locals {

  eks_worker_userdata = <<USERDATA

#!/bin/bash

set -o xtrace

# Apply to the controlplane to connect this node to the Kubernetes cluster
/etc/eks/bootstrap.sh \
  --apiserver-endpoint '${aws_eks_cluster.environment.endpoint}' \
  --b64-cluster-ca '${aws_eks_cluster.environment.certificate_authority.0.data}' \
  '${var.cluster-name}'
USERDATA
}
