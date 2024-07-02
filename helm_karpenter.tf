# resource "helm_release" "karpenter" {
#   namespace        = "karpenter"
#   create_namespace = true

#   name       = "karpenter"
#   repository = "oci://public.ecr.aws/karpenter"
#   chart      = "karpenter"
#   version    = "0.37.0"

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.karpenter_controller.arn
#   }

#   set {
#     name  = "settings.clusterName"
#     value = var.cluster_name
#   }

#   set {
#     name  = "settings.clusterEndpoint"
#     value = aws_eks_cluster.eks_cluster.endpoint
#   }

#   set {
#     name  = "settings.aws.defaultInstanceProfile"
#     value = aws_iam_instance_profile.karpenter.name
#   }

#   set {
#     name  = "replicas"
#     value = "1"
#   }

#   depends_on = [aws_eks_node_group.cluster]
# }

# resource "time_sleep" "wait_15_seconds_karpenter" {
#   depends_on = [helm_release.karpenter]

#   create_duration = "15s"
# }

# resource "kubectl_manifest" "karpenter-nodeclass" {
#   yaml_body = <<YAML
# apiVersion: karpenter.k8s.aws/v1beta1
# kind: EC2NodeClass
# metadata:
#   name: ${var.cluster_name}-default
# spec:
#   amiFamily: AL2
#   role: role-${var.cluster_name}-${var.environment}-eks-nodes
#   subnetSelectorTerms:
#     - tags:
#         karpenter.sh/discovery: "true"
#   securityGroupSelectorTerms:
#     - tags:
#         aws:eks:cluster-name: ${var.cluster_name}
#   blockDeviceMappings:
#     - deviceName: /dev/xvda
#       ebs:
#         volumeSize: 30Gi
#         volumeType: gp3
#         iops: 3000
#         encrypted: true
#         deleteOnTermination: true
#         throughput: 125
# YAML

#   depends_on = [
#     kubernetes_config_map.aws-auth,
#     helm_release.karpenter,
#     time_sleep.wait_15_seconds_karpenter
#   ]
# }

# resource "kubectl_manifest" "karpenter-nodepool-default" {
#   yaml_body = <<YAML
# apiVersion: karpenter.sh/v1beta1
# kind: NodePool
# metadata:
#   name: ${var.cluster_name}-default
# spec:
#   template:
#     spec:
#       requirements:
#         - key: karpenter.k8s.aws/instance-size
#           operator: In
#           values: [${join(",", [for instance_size in var.karpenter_instance_size : "\"${instance_size}\""])}]
#         - key: karpenter.k8s.aws/instance-family
#           operator: In
#           values: [${join(",", [for instance_class in var.karpenter_instance_class : "\"${instance_class}\""])}]
#         - key: kubernetes.io/os
#           operator: In
#           values: ["linux"]
#         - key: karpenter.sh/capacity-type
#           operator: In
#           values: ["spot"]
#         - key: "topology.kubernetes.io/zone"
#           operator: In
#           values: [${join(",", [for az in var.karpenter_azs : "\"${az}\""])}]
#       nodeClassRef:
#         apiVersion: karpenter.k8s.aws/v1beta1
#         kind: EC2NodeClass
#         name: ${var.cluster_name}-default
#   limits:
#     cpu: 1000
#   disruption:
#     consolidationPolicy: WhenUnderutilized
#     expireAfter: 72h
# YAML

#   depends_on = [
#     kubernetes_config_map.aws-auth,
#     helm_release.karpenter,
#     time_sleep.wait_15_seconds_karpenter
#   ]
# }
