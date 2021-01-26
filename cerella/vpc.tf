#
# @author GDev
# @date November 2020
#

resource "aws_vpc" "environment" {

  cidr_block = var.cidr

  tags = {
    "Name"                                      = var.cluster-name
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_subnet" "left" {

  availability_zone = var.left_availability_zone
  cidr_block        = var.left_subnet_cidr
  vpc_id            = aws_vpc.environment.id

  tags = {
    "Name"                                      = var.cluster-name
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_subnet" "right" {

  availability_zone = var.right_availability_zone
  cidr_block        = var.right_subnet_cidr
  vpc_id            = aws_vpc.environment.id

  tags = {
    "Name"                                      = var.cluster-name
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_internet_gateway" "environment" {

  vpc_id = aws_vpc.environment.id

  tags = {
    "Name"                                      = var.cluster-name
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_route_table" "environment" {

  vpc_id = aws_vpc.environment.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.environment.id
  }
}

resource "aws_route_table_association" "left" {

  subnet_id      = aws_subnet.left.id
  route_table_id = aws_route_table.environment.id
}

resource "aws_route_table_association" "right" {

  subnet_id      = aws_subnet.right.id
  route_table_id = aws_route_table.environment.id
}
