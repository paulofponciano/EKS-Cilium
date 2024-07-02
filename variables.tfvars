## PROJECT BASE

cluster_name = "pegasus-cilium"
environment  = "staging"
project      = "devops"
aws_region   = "us-east-2"
az1          = "us-east-2a"
az2          = "us-east-2b"

## CLUSTER OPTIONS

k8s_version = "1.29"

endpoint_private_access = true

instance_type = [
  "m5.large"
]

desired_size = "3"
min_size     = "3"
max_size     = "3"

enabled_cluster_log_types = [
  "api", "audit", "authenticator", "controllerManager", "scheduler"
]

addon_csi_version = "v1.32.0-eksbuild.1"
# addon_cni_version       = "v1.18.2-eksbuild.1"
addon_coredns_version   = "v1.11.1-eksbuild.9"
#addon_kubeproxy_version = "v1.30.0-eksbuild.3"
addon_kubeproxy_version = "v1.29.3-eksbuild.5"

## INGRESS OPTIONS (CILIUM NLB)

nlb_ingress_internal = "false"
enable_cross_zone_lb = "true"
nlb_ingress_type     = "network"
proxy_protocol_v2    = "false"
cilium_hubble_host   = "hubble.pauloponciano.digital"
grafana_host         = "grafana.pauloponciano.digital"
prometheus_host      = "prometheus.pauloponciano.digital"

## KARPENTER OPTIONS

# karpenter_instance_class = [
#   "m5",
#   "c5",
#   "t3a"
# ]
# karpenter_instance_size = [
#   "large",
#   "2xlarge"
# ]
# karpenter_capacity_type = [
#   "spot"
# ]
# karpenter_azs = [
#   "us-east-2a",
#   "us-east-2b"
# ]

## LOKI / TEMPO OPTIONS

loki_bucket_name  = "loki2-s3-paulop"
tempo_bucket_name = "tempo2-s3-paulop"

## NETWORKING

vpc_cidr                = "10.0.0.0/16"
public_subnet_az1_cidr  = "10.0.16.0/20"
public_subnet_az2_cidr  = "10.0.32.0/20"
private_subnet_az1_cidr = "10.0.48.0/20"
private_subnet_az2_cidr = "10.0.64.0/20"
