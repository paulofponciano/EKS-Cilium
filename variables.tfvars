## PROJECT BASE

cluster_name = "pegasus-2"
environment  = "staging"
project      = "devops"
aws_region   = "us-west-2"
az1          = "us-west-2a"
az2          = "us-west-2b"

## CLUSTER OPTIONS

k8s_version = "1.29"

endpoint_private_access = true

instance_type = [
  "m5a.large"
]

desired_size = "1"
min_size     = "1"
max_size     = "1"

enabled_cluster_log_types = [
  "api", "audit", "authenticator", "controllerManager", "scheduler"
]

addon_csi_version       = "v1.29.1-eksbuild.1"
addon_cni_version       = "v1.17.1-eksbuild.1"
addon_coredns_version   = "v1.11.1-eksbuild.6"
addon_kubeproxy_version = "v1.29.1-eksbuild.2"

## INGRESS OPTIONS (CILIUM NLB)

nlb_ingress_internal = "false"
enable_cross_zone_lb = "true"
nlb_ingress_type     = "network"
proxy_protocol_v2    = "false"
cilium_hubble_host   = "hubble.pauloponciano.digital"

## KARPENTER OPTIONS

## If you change the number of items in the lists, you need to check the file helm_karpenter.tf > resource "kubectl_manifest" "karpenter-nodepool-default"

karpenter_instance_class = [
  "m5",
  "c5",
  "t3a"
]
karpenter_instance_size = [
  "large",
  "2xlarge"
]
karpenter_capacity_type = [
  "spot"
]
karpenter_azs = [
  "us-west-2a",
  "us-west-2b"
]

## NETWORKING

vpc_cidr                = "10.0.0.0/16"
public_subnet_az1_cidr  = "10.0.16.0/20"
public_subnet_az2_cidr  = "10.0.32.0/20"
private_subnet_az1_cidr = "10.0.48.0/20"
private_subnet_az2_cidr = "10.0.64.0/20"
