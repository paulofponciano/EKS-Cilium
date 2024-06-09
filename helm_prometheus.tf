resource "helm_release" "prometheus" {
  name             = "prometheus"
  chart            = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = "prometheus"
  create_namespace = true

  version = "57.2.0"


  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.cluster,
    kubernetes_config_map.aws-auth,
    helm_release.karpenter,
    kubectl_manifest.karpenter-nodeclass,
    kubectl_manifest.karpenter-nodepool-default,
    time_sleep.wait_30_seconds_karpenter
  ]
}

resource "kubectl_manifest" "grafana_gateway" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: grafana
  namespace: prometheus
spec:
  selector:
    istio: ingressgateway 
  servers:
  - port:
      number: 443
      name: http
      protocol: HTTP
    hosts:
    - ${var.grafana_virtual_service_host}
YAML

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.cluster,
    kubernetes_config_map.aws-auth,
    helm_release.cilium,
    helm_release.prometheus,
    helm_release.karpenter,
    time_sleep.wait_30_seconds_karpenter
  ]

}

resource "kubectl_manifest" "grafana_service" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: grafana
  namespace: prometheus
spec:
  hosts:
  - ${var.grafana_virtual_service_host}
  gateways:
  - grafana
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: prometheus-grafana
        port:
          number: 80
YAML

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.cluster,
    kubernetes_config_map.aws-auth,
    helm_release.cilium,
    helm_release.prometheus,
    helm_release.karpenter,
    time_sleep.wait_30_seconds_karpenter
  ]

}