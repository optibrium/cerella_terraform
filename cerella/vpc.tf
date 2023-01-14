#
# @author GDev
# @date November 2021
#

resource "aws_vpc" "environment" {
  count      = local.create_vpc ? 1 : 0
  cidr_block = var.cidr

  tags = {
    "Name"                                      = var.cluster-name
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_subnet" "left" {
  count             = local.create_vpc ? 1 : 0
  availability_zone = var.left-availability-zone
  cidr_block        = var.left-subnet-cidr
  vpc_id            = local.vpc_id

  tags = {
    "Name"                                      = var.cluster-name
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_subnet" "right" {
  count             = local.create_vpc ? 1 : 0
  availability_zone = var.right-availability-zone
  cidr_block        = var.right-subnet-cidr
  vpc_id            = local.vpc_id

  tags = {
    "Name"                                      = var.cluster-name
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_internet_gateway" "environment" {
  count  = local.create_vpc ? 1 : 0
  vpc_id = local.vpc_id

  tags = {
    "Name"                                      = var.cluster-name
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_route_table" "environment" {
  count  = local.create_vpc ? 1 : 0
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.environment[0].id
  }
}

resource "aws_route_table_association" "left" {
  count          = local.create_vpc ? 1 : 0
  subnet_id      = aws_subnet.left[0].id
  route_table_id = aws_route_table.environment[0].id
}

resource "aws_route_table_association" "right" {
  count          = local.create_vpc ? 1 : 0
  subnet_id      = aws_subnet.right[0].id
  route_table_id = aws_route_table.environment[0].id
}
