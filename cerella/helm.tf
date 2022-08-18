#
# @author GDev
# @date November 2021
#

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.environment.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.environment.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.environment_auth.token
  }
}

resource "helm_release" "ingress" {
  name       = "ingress"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  version    = var.ingress-version
  depends_on = [aws_autoscaling_group.workers]

  set {
    name  = "controller.replicaCount"
    value = "1"
  }

  set {
    name  = "controller.healthStatus"
    value = "true"
  }

  set {
    name  = "controller.kind"
    value = "daemonset"
  }

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  set {
    name  = "controller.service.httpPort.nodePort"
    value = var.cluster-ingress-port
  }

  set {
    name  = "prometheus.create"
    value = true
  }

  set {
    name  = "controller.enableLatencyMetrics"
    value = true
  }

  set {
    name  = "controller.setAsDefaultIngress"
    value = true
  }

  set {
    name  = "controller.config.entries.proxy-body-size"
    value = "2000m"
  }

  set {
    name  = "controller.config.entries.client-max-body-size"
    value = "2000m"
  }

  set {
    name  = "controller.config.entries.max-body-size"
    value = "2000m"
  }

  set {
    name  = "controller.config.entries.proxy-read-timeout"
    value = "300s"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.prometheus-chart-version
  depends_on = [aws_autoscaling_group.workers]

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = "gp2"
  }
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]"
    value = "ReadWriteOnce"
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = "20Gi"
  }

  set {
    name  = "prometheus.prometheusSpec.podMetadata.annotations.cluster-autoscaler\\.kubernetes\\.io/safe-to-evict"
    value = "\"true\""
  }

  set {
    name  = "alertmanager.enabled"
    value = false
  }

  set {
    name  = "grafana.podAnnotations.cluster-autoscaler\\.kubernetes\\.io/safe-to-evict"
    value = "\"true\""
  }

}

resource "helm_release" "cluster_autoscaler" {
  name       = "autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  depends_on = [aws_eks_cluster.environment]
  namespace  = "kube-system"
  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster-name
  }
  set {
    name  = "cloudProvider"
    value = "aws"
  }
  set {
    name  = "awsRegion"
    value = var.region
  }
  set {
    name  = "image.tag"
    value = var.cluster-autoscaler-version
  }

}

resource "kubernetes_namespace" "blue" {
  metadata {
    annotations = {
      name = "blue"
    }

    labels = {
      purpose = "blue"
    }

    name = "blue"
  }
}

resource "kubernetes_default_service_account" "blue" {
  metadata {
    namespace = "blue"
  }
  image_pull_secret {
    name = "blue-regcred"
  }
}

resource "kubernetes_secret" "blue-docker-logins" {
  metadata {
    name      = "blue-regcred"
    namespace = "blue"
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "https://index.docker.io/v1/" = {
          auth = "${base64encode("${var.registry_username}:${var.registry_password}")}"
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_namespace" "green" {
  metadata {
    annotations = {
      name                             = "green"
      "meta.helm.sh/release-name"      = "green"
      "meta.helm.sh/release-namespace" = "default"
    }

    labels = {
      purpose                        = "green"
      "app.kubernetes.io/managed-by" = "Helm"
    }

    name = "green"
  }
}

resource "kubernetes_default_service_account" "green" {
  metadata {
    namespace = "green"
  }
  image_pull_secret {
    name = "green-regcred"
  }
}

resource "kubernetes_secret" "green-docker-logins" {
  metadata {
    name      = "green-regcred"
    namespace = "green"
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "https://index.docker.io/v1/" = {
          auth = "${base64encode("${var.registry_username}:${var.registry_password}")}"
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  depends_on = [aws_eks_cluster.environment]
  namespace  = "kube-system"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${module.external_secret_iam_role.iam_role_name}"
  }
}
