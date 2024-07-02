resource "helm_release" "promtail" {
  name       = "promtail"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  namespace  = "prometheus"

  version = "6.15.4"

  values = [
    "${file("./loki/promtail-values.yaml")}"
  ]

  depends_on = [
    helm_release.cilium
  ]
}

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-distributed"
  namespace  = "prometheus"

  version = "0.78.2"

  values = [
    "${file("./loki/loki-values.yaml")}"
  ]

  set {
    name  = "loki.storageConfig.aws.region"
    value = var.aws_region
  }

  set {
    name  = "loki.storageConfig.aws.bucketnames"
    value = var.loki_bucket_name
  }

  set {
    name  = "serviceAccount.create"
    value = true
  }

  set {
    name  = "serviceAccount.name"
    value = "loki-sa"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.loki_tempo_service_account_role.arn
  }

  depends_on = [
    helm_release.cilium,
    helm_release.promtail,
    aws_iam_role.loki_tempo_service_account_role,
    aws_s3_bucket.loki_bucket
  ]
}

resource "helm_release" "tempo" {
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo-distributed"
  namespace  = "prometheus"

  version = "1.8.2"

  values = [
    "${file("./loki/tempo-values.yaml")}"
  ]

  set {
    name  = "serviceAccount.create"
    value = true
  }

  set {
    name  = "serviceAccount.name"
    value = "tempo-sa"
  }

  set {
    name  = "serviceAccount.automountServiceAccountToken"
    value = true
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.loki_tempo_service_account_role.arn
  }

  set {
    name  = "storage.trace.backend"
    value = "s3"
  }

  set {
    name  = "storage.trace.s3.bucket"
    value = var.tempo_bucket_name
  }

  set {
    name  = "storage.trace.s3.endpoint"
    value = "s3.${var.aws_region}.amazonaws.com"
  }

  set {
    name  = "traces.otlp.grpc.enabled"
    value = true
  }

  depends_on = [
    helm_release.cilium,
    helm_release.loki,
    aws_iam_role.loki_tempo_service_account_role,
    aws_s3_bucket.tempo_bucket
  ]
}
