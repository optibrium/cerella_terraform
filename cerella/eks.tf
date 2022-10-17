#
# @author GDev
# @date Feb 2022
#

resource "aws_ebs_encryption_by_default" "ebs_encryption" {
  enabled = true
}

resource "aws_eks_cluster" "environment" {
  name     = var.cluster-name
  role_arn = aws_iam_role.control_plane.arn
  version  = var.eks-version
  depends_on = [
    aws_ebs_encryption_by_default.ebs_encryption
  ]

  vpc_config {
    security_group_ids = [aws_security_group.control_plane.id]
    subnet_ids         = [aws_subnet.right.id, aws_subnet.left.id]
  }
}

data "aws_ami" "eks_ami" {

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks-version}-v*"]
  }

  most_recent = true
  owners      = ["amazon"]
}

resource "aws_launch_configuration" "workers" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.worker_nodes.name
  image_id                    = data.aws_ami.eks_ami.image_id
  instance_type               = var.eks-instance-type
  key_name                    = "cerella-${var.cluster-name}"
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
  name                      = "worker_nodes-${var.cluster-name}"
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

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
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

data "aws_caller_identity" "current" {}

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
- rolearn: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSControlTowerExecution"
  username: ControlTowerAccess
  groups:
    - system:masters
AUTH
  }

  depends_on = [aws_eks_cluster.environment]
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

resource "aws_key_pair" "cerella_ssh_key" {
  key_name   = "cerella-${var.cluster-name}"
  public_key = file("${path.module}/template/ssh_pub.tpl")
}

data "tls_certificate" "environment" {
  url        = aws_eks_cluster.environment.identity.0.oidc.0.issuer
  depends_on = [aws_eks_cluster.environment]
}
resource "aws_iam_openid_connect_provider" "oidc_identity_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.environment.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.environment.identity.0.oidc.0.issuer
  depends_on      = [aws_eks_cluster.environment]
}

locals {
  provider_url = replace(flatten(concat(aws_eks_cluster.environment[*].identity[*].oidc.0.issuer, [""]))[0], "https://", "")
  depends_on   = [aws_iam_openid_connect_provider.oidc_identity_provider]
}

# Addon
# Kube Proxy
resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.environment.name
  addon_name        = "kube-proxy"
  addon_version     = var.kube_proxy_addon_version
  resolve_conflicts = "OVERWRITE"
  depends_on        = [aws_eks_cluster.environment]
}

# Kube Proxy
resource "aws_eks_addon" "vpc_cni" {
  cluster_name      = aws_eks_cluster.environment.name
  addon_name        = "vpc-cni"
  addon_version     = var.vpc_cni_addon_version
  resolve_conflicts = "OVERWRITE"
  depends_on        = [aws_eks_cluster.environment]
}

# Coredns
resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.environment.name
  addon_name        = "coredns"
  addon_version     = var.coredns_addon_version
  resolve_conflicts = "OVERWRITE"
  depends_on        = [aws_eks_cluster.environment]
}

module "eks_workers_asg" {
  source               = "./modules/eks_workers_asg"
  cluster_name         = var.cluster-name
  eks_subnet_ids       = [aws_subnet.right.id, aws_subnet.left.id]
  eks_cluster_endpoint = aws_eks_cluster.environment.endpoint
  security_group_ids   = [aws_security_group.worker_nodes.id]
  eks_cluster_ca_cert  = aws_eks_cluster.environment.certificate_authority.0.data
  eks_cluster_region   = var.region
  instance_type = "t3.small"
  disk_size = "20"
  disk_type = "gp2"
}
