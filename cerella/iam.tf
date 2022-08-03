#
# @author GDev
# @date November 2021
#

resource "aws_iam_role" "control_plane" {

  name = "eks_control_plane-${var.cluster-name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "control_plane-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.control_plane.name
}

resource "aws_iam_role_policy_attachment" "control_plane-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.control_plane.name
}

resource "aws_iam_role_policy_attachment" "control_plane-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.control_plane.name
}

resource "aws_iam_role" "worker_nodes" {

  name = "worker_nodes_${var.cluster-name}"

  assume_role_policy = data.aws_iam_policy_document.d_workers.json

}
data "aws_iam_policy_document" "d_workers" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role_policy_attachment" "worker_nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker_nodes.name
}

resource "aws_iam_role_policy_attachment" "worker_nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker_nodes.name
}

resource "aws_iam_role_policy_attachment" "worker_nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker_nodes.name
}

resource "aws_iam_role_policy_attachment" "worker_nodes_ssm_access" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role       = aws_iam_role.worker_nodes.name
}

resource "aws_iam_instance_profile" "worker_nodes" {
  name = "worker_nodes_${var.cluster-name}"
  role = aws_iam_role.worker_nodes.name
}

data "aws_iam_policy_document" "worker_nodes_describe_tags" {
  statement {
    actions = ["ec2:DescribeTags"]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "worker_nodes_describe_tags" {
  name_prefix = "eks-worker-tags-"
  role        = aws_iam_role.worker_nodes.id
  policy      = data.aws_iam_policy_document.worker_nodes_describe_tags.json
}

data "aws_iam_policy_document" "worker_nodes_cluster_autoscaler_action" {
  statement {
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "worker_nodes_cluster_autoscaler_action" {
  name_prefix = "eks-worker-autoscaler-action-"
  role        = aws_iam_role.worker_nodes.id
  policy      = data.aws_iam_policy_document.worker_nodes_cluster_autoscaler_action.json
}

data "aws_iam_policy_document" "worker_nodes_cluster_autoscaler_describe" {
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeTags",
      "autoscaling:DescribeLaunchConfigurations",
      "ec2:DescribeInstanceTypes",
      "eks:DescribeNodegroup",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "worker_nodes_cluster_autoscaler_describe" {
  name_prefix = "eks-worker-autoscaler-describe-"
  role        = aws_iam_role.worker_nodes.id
  policy      = data.aws_iam_policy_document.worker_nodes_cluster_autoscaler_describe.json
}

# IAM Role for IRSA
data "aws_iam_policy_document" "irsa" {
  statement {
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.provider_url}"]
    }
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test     = "StringEquals"
      variable = "${local.provider_url}:sub"
      values   = ["system:serviceaccount:${var.service-account-namespace}:${var.service-account-name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "irsa" {
  name               = "${var.irsa_iam_role_name}-${var.cluster-name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.irsa.json
}

data "aws_iam_policy_document" "external_secret_readonly" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]

    resources = [
      "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:CERELLA_*"
    ]

  }
}

resource "aws_iam_role_policy" "external_secret_readonly" {
  name_prefix = "external-secret-readonly-"
  role        = aws_iam_role.irsa.id
  policy      = data.aws_iam_policy_document.external_secret_readonly.json
}