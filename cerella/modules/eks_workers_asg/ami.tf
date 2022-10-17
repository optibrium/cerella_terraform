data "aws_ami" "eks_ami" {

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks-version}-v*"]
  }

  most_recent = true
  owners      = ["amazon"]
}