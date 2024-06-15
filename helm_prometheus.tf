resource "helm_release" "prometheus" {
  name             = "prometheus"
  chart            = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = "prometheus"
  create_namespace = true

  version = "60.1.0"

  values = [
    "${file("./prometheus/values.yaml")}"
  ]

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.cluster,
    kubernetes_config_map.aws-auth,
    helm_release.karpenter,
    kubectl_manifest.karpenter-nodeclass,
    kubectl_manifest.karpenter-nodepool-default,
    time_sleep.wait_15_seconds_karpenter
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
    helm_release.karpenter,
    time_sleep.wait_15_seconds_karpenter,
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
    helm_release.karpenter,
    time_sleep.wait_15_seconds_karpenter,
    helm_release.cilium
  ]
}
