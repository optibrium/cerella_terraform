#
# @author GDev
# @date November 2020
#

resource "aws_security_group" "worker_nodes" {
  description = "worker node communication"
  name        = "worker_nodes"
  vpc_id      = aws_vpc.environment.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                      = var.cluster-name
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_security_group" "control_plane" {
  description = "cluster endpoint communication"
  name        = "control_plane"
  vpc_id      = aws_vpc.environment.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                      = var.cluster-name
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_security_group" "ingress" {
  description = "entry via the LB"
  name        = "ingress"
  vpc_id      = aws_vpc.environment.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                      = var.cluster-name
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_security_group_rule" "office-control-plane-https" {
  cidr_blocks       = var.ingress-cidr
  description       = "Allow user site to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.control_plane.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "office-workers-ssh" {
  cidr_blocks       = var.ingress-cidr
  description       = "Allow office to communicate with the worker nodes"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.worker_nodes.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "office-https-to-LB" {
  cidr_blocks       = var.ingress-cidr
  description       = "Allows HTTPS access to the LB"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ingress.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "worker-nodes-to-control-plane-https" {
  source_security_group_id = aws_security_group.worker_nodes.id
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.control_plane.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "control-plane-to-worker-kublet" {
  source_security_group_id = aws_security_group.control_plane.id
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker_nodes.id
  to_port                  = 10250
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker-nodes-to-worker-nodes" {
  source_security_group_id = aws_security_group.worker_nodes.id
  description              = "Inter-node communication"
  from_port                = 0
  protocol                 = -1
  security_group_id        = aws_security_group.worker_nodes.id
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "LB-ingress-to-worker-nodes" {
  source_security_group_id = aws_security_group.ingress.id
  description              = "Allow LB to forward https traffic to the workers"
  from_port                = var.cluster-ingress-port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker_nodes.id
  to_port                  = var.cluster-ingress-port
  type                     = "ingress"
}
