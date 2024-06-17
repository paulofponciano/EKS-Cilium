## DATA

data "aws_eks_cluster_auth" "default" {
  name = aws_eks_cluster.eks_cluster.id
}

data "aws_caller_identity" "current" {}

## CLUSTER

resource "aws_eks_cluster" "eks_cluster" {

  name     = var.cluster_name
  version  = var.k8s_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    endpoint_private_access = var.endpoint_private_access

    security_group_ids = [
      aws_security_group.cluster_sg.id,
      aws_security_group.cluster_nodes_sg.id
    ]

    subnet_ids = [
      aws_subnet.private_subnet_az1.id,
      aws_subnet.private_subnet_az2.id,
    ]

  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "Environment"                               = "${var.environment}"
    "Project"                                   = "${var.project}"
    Terraform                                   = true
  }

}

## NODE GROUP

resource "aws_eks_node_group" "cluster" {

  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = join("-", [aws_eks_cluster.eks_cluster.name, var.environment, "nodegroup", var.aws_region])
  node_role_arn   = aws_iam_role.eks_nodes_roles.arn

  subnet_ids = [
    aws_subnet.private_subnet_az1.id,
    aws_subnet.private_subnet_az2.id,
  ]

  instance_types = var.instance_type

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  labels = {
    "ingress/ready" = "true"
  }

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned",
    "Environment"                               = "${var.environment}"
    "Project"                                   = "${var.project}"
    Terraform                                   = true
  }

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }

  # taint {
  #   key    = "role"
  #   value  = "core"
  #   effect = "NO_EXECUTE"
  # }

  depends_on = [
    kubernetes_config_map.aws-auth
  ]
}

resource "aws_autoscaling_group_tag" "tag_name" {
  autoscaling_group_name = aws_eks_node_group.cluster.resources[0].autoscaling_groups[0].name

  tag {
    key   = "Name"
    value = "worker-node-${var.cluster_name}"

    propagate_at_launch = true
  }

  depends_on = [
    aws_eks_node_group.cluster
  ]
}
