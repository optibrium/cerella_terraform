#
# @author GDev
# @date November 2020
#

resource "aws_iam_role" "control_plane" {

  name = "eks_control_plane"

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

  name = "worker_nodes"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
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

resource "aws_iam_instance_profile" "worker_nodes" {
  name = "worker_nodes"
  role = aws_iam_role.worker_nodes.name
}

resource "aws_iam_user" "optibrium" {
  name = "optibrium"
  path = "/"

  tags = {
    Name = "optibrium"
  }
}

resource "aws_key_pair" "optibrium" {
  key_name   = "optibrium"
  public_key = file("${path.module}/template/ssh_pub.tpl")
}

resource "aws_iam_access_key" "optibrium" {
  user    = aws_iam_user.optibrium.name
  pgp_key = file("${path.module}/template/pgp_pub.b64.tpl")
}

resource "aws_iam_user_policy" "optibrium" {
  name = "optibrium-cerella-eks-access"
  user = aws_iam_user.optibrium.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "eks:*"
          ],
          "Resource": "${aws_eks_cluster.environment.arn}"
      },
      {
          "Effect": "Allow",
          "Action": "iam:PassRole",
          "Resource": "*",
          "Condition": {
              "StringEquals": {
                  "iam:PassedToService": "eks.amazonaws.com"
              }
          }
      }
  ]
}
EOF
}
