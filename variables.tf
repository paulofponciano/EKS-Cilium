variable "cluster_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "az1" {
  type = string
}

variable "az2" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "instance_type" {
  type = list(string)
}

variable "enabled_cluster_log_types" {
  type = list(string)
}

variable "endpoint_private_access" {
  type = bool
}

variable "desired_size" {
  type = string
}

variable "min_size" {
  type = string
}

variable "max_size" {
  type = string
}

variable "karpenter_instance_class" {
  type = list
}

variable "karpenter_instance_size" {
  type = list 
}

variable "karpenter_capacity_type" {
  type = list
}

variable "karpenter_azs" {
  type = list
}

variable "nlb_ingress_internal" {
  type = bool
}

variable "enable_cross_zone_lb" {
  type = bool
}

variable "nlb_ingress_type" {
  type = string
}

variable "proxy_protocol_v2" {
  type = bool
}

variable "cilium_hubble_host" {
  type = string
}

variable "addon_cni_version" {
  type        = string
  description = "VPC CNI Version"
}

variable "addon_coredns_version" {
  type        = string
  description = "CoreDNS Version"
}

variable "addon_kubeproxy_version" {
  type        = string
  description = "Kubeproxy Version"
}

variable "addon_csi_version" {
  type        = string
  description = "CSI Version"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
}

variable "public_subnet_az1_cidr" {
  type        = string
  description = "Public Subnet CIDR"
}

variable "public_subnet_az2_cidr" {
  type        = string
  description = "Public Subnet CIDR"
}

variable "private_subnet_az1_cidr" {
  type        = string
  description = "Private Subnet CIDR"
}

variable "private_subnet_az2_cidr" {
  type        = string
  description = "Private Subnet CIDR"
}
