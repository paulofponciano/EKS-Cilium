output "cilium_ingress_nlb" {
  value = aws_lb.cilium_ingress.dns_name
}

output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}