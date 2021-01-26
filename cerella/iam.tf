#
# @author GDev
# @date November 2020
#

resource "aws_key_pair" "optibrium" {
  key_name   = "optibrium"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhJsw7dQ6M1XDQ1w+gW+FSMEpwvKGQkBhpB9Xa66juaFb6t9f7kK1zgnjXxq9Ix58xApFWYB0vSZoZUqqLTDE+O1uwh/Yx+lOhAFMgViwWelvvwG1wjWC/NIKspkqRPlJbZgSZKTDnUTc0jvk7UkP6A+OM0AvjnERod8dMm4ZdtOPQaLQJsuVhccI/IG53uevCGTcNljYkAPNYjypBrSRdHNQ8Ask4CbqJLq0QTlWpURzbwamU9P/bl6SypoDB8UlqRK95USv3ptOsovQnYfwHQ/QNWHAPwpzh+42CfF/BWqcMaDKLiZBSDcIwk1r3oKhmryi1YlC6dgIUzU5sY7INgiHniuyMIkRnfx40M9cS6xCBwn3+DjPioAU9nTCW9UH2Dqz3o1p3UwEvzfTNcdN3SdCf1clb9XrXLFDHYxfvOp324fPooycctVz4GG6CM1GlrIURE9NEL8evBB4uYICNzWduOc57fDLvHqdJJL1FXTcJOsw0d6v2th0Gw9nxXZYyFTeISkCX68l1OPhQILBrKocVR0J8sVTmlqCpd+oxGbFKBDAZSEu74pX6H85OcwaRwZGBOoQk0/VXYHzYZmrQGyVKbAMTpkTbjFOY0W410HvWT4Z2uMCSV3zd4OLpO2WcA4OGvSUkXqhLOMlsc0nfzfm7rfFaYra3pcUEeMp+rw== optibrium.cerella.ai"
}

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

resource "aws_iam_policy" "S3-access" {
  name        = "cerella-s3-access"
  path        = "/"
  description = "Allow access to S3 for seed files"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.s3-bucket-id}/*"
    }
  ]
}
EOF
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

resource "aws_iam_role_policy_attachment" "worker_nodes_s3_access" {
  policy_arn = aws_iam_policy.S3-access.arn
  role       = aws_iam_role.worker_nodes.name
}

resource "aws_iam_instance_profile" "worker_nodes" {
  name = "worker_nodes"
  role = aws_iam_role.worker_nodes.name
}
