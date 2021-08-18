#
# @author GDev
# @date August 2021
#

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.environment.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.environment.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.environment_auth.token
  }
}

resource "random_password" "model_override_token" {
  length  = 56
  special = true
}

resource "random_password" "aaa_database_password" {
  length  = 56
  special = true
}

resource "helm_release" "ingress" {
  name       = "ingress"
  repository = "http://helm.cerella.ai"
  chart      = "cerella_ingress"
  version    = var.cerella-version
  depends_on = [aws_eks_cluster.environment]

  set {
    name  = "domain"
    value = var.domain
  }

  set {
    name  = "aws.ingressport"
    value = var.cluster-ingress-port
  }

  set {
    name  = "aws.ingressPodCount"
    value = var.eks-instance-count
  }
}

resource "helm_release" "green_zone" {
  name       = "green"
  repository = "http://helm.cerella.ai"
  chart      = "cerella_green"
  version    = var.cerella-version
  depends_on = [aws_eks_cluster.environment]

  # The Green Zone contains Alchemite, which will not
  # come up healthy at first, as there will not be any
  # models yet. Waiting for health means apply will fail.
  wait       = false

  set {
    name  = "domain"
    value = var.domain
  }

  set_sensitive {
    name  = "dockerConfigJson"
    value = var.docker-config
  }

  set_sensitive {
    name  = "storage_server.MODEL_DOWNLOAD_TOKEN"
    value = random_password.model_override_token.result
  }

  set_sensitive {
    # TODO: change with v1
    name  = "aaa.POSTGRES_PASSWORD"
    value = random_password.aaa_database_password.result
  }
}
