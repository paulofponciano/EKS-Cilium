resource "helm_release" "prometheus" {
  name             = "prometheus"
  chart            = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = "prometheus"
  create_namespace = true

  #version = "60.1.0"
  version = "56.6.0"

  values = [
    "${file("./prometheus/values.yaml")}"
  ]

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.cluster,
    kubernetes_config_map.aws-auth,
    # helm_release.karpenter,
    # kubectl_manifest.karpenter-nodeclass,
    # kubectl_manifest.karpenter-nodepool-default,
    # time_sleep.wait_15_seconds_karpenter
  ]
}

resource "kubectl_manifest" "prometheus_all_pod_monitor" {

  count = 0

  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: generic-stats-monitor
  namespace: prometheus
  labels:
    monitoring: istio-proxies
    release: istio
spec:
  selector:
    matchExpressions:
    - {key: istio-prometheus-ignore, operator: DoesNotExist}
  namespaceSelector:
    any: true
  jobLabel: generic-stats
  podMetricsEndpoints:
  - path: /metrics
    interval: 15s
    relabelings:
    - action: keep
YAML

  depends_on = [
    helm_release.prometheus
  ]
}

resource "kubernetes_config_map" "grafana_dashboard_tetragon" {
  metadata {
    name      = "tetragon-dashboard"
    namespace = "prometheus"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "tetragon.json" = file("./prometheus/Tetragon_Events.json")
  }

  depends_on = [
    helm_release.prometheus
  ]
}

resource "kubernetes_config_map" "grafana_dashboard_hubble" {
  metadata {
    name      = "hubble-l7-http-dashboard"
    namespace = "prometheus"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "hubble.json" = file("./prometheus/Hubble_L7_HTTP_Metrics.json")
  }

  depends_on = [
    helm_release.prometheus
  ]
}

resource "kubectl_manifest" "grafana_ingress" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: prometheus
spec:
  ingressClassName: cilium
  rules:
  - host: ${var.grafana_host}
    http:
      paths:
      - backend:
          service:
            name: prometheus-grafana
            port:
              number: 80
        path: /
        pathType: Prefix
YAML

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.cluster,
    kubernetes_config_map.aws-auth,
    # helm_release.karpenter,
    # time_sleep.wait_15_seconds_karpenter,
    helm_release.cilium
  ]
}

resource "kubectl_manifest" "prometheus_ingress" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: prometheus-ingress
  namespace: prometheus
spec:
  ingressClassName: cilium
  rules:
  - host: ${var.prometheus_host}
    http:
      paths:
      - backend:
          service:
            name: prometheus-kube-prometheus-prometheus
            port:
              number: 9090
        path: /
        pathType: Prefix
YAML

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.cluster,
    kubernetes_config_map.aws-auth,
    # helm_release.karpenter,
    # time_sleep.wait_15_seconds_karpenter,
    helm_release.cilium
  ]
}
