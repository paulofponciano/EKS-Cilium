## ALB INGRESS CONTROLLER

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "alb_controller" {
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role.json
  name               = join("-", ["role", var.cluster_name, var.environment, "alb-controller"])
}

data "aws_iam_policy_document" "aws_load_balancer_controller_policy" {
  version = "2012-10-17"

  statement {

    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
      "ec2:GetCoipPoolUsage",
      "ec2:DescribeCoipPools",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:SetWebAcl",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:ModifyRule"
    ]

    resources = [
      "*"
    ]

  }

  statement {

    effect = "Allow"
    actions = [
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets"
    ]

    resources = [
      "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
    ]

  }

  statement {

    effect = "Allow"
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags"
    ]

    resources = [
      "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
    ]

  }

}

resource "aws_iam_policy" "aws_load_balancer_controller_policy" {
  name        = join("-", ["policy", var.cluster_name, var.environment, "alb-controller"])
  path        = "/"
  description = var.cluster_name

  policy = data.aws_iam_policy_document.aws_load_balancer_controller_policy.json
}

resource "aws_iam_policy_attachment" "aws_load_balancer_controller_policy" {
  name = "aws_load_balancer_controller_policy"

  roles = [aws_iam_role.alb_controller.name]

  policy_arn = aws_iam_policy.aws_load_balancer_controller_policy.arn
}

## NODES

data "aws_iam_policy_document" "eks_nodes_role" {

  version = "2012-10-17"

  statement {

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }

  }

}

resource "aws_iam_role" "eks_nodes_roles" {
  name               = join("-", ["role", var.cluster_name, var.environment, "eks-nodes"])
  assume_role_policy = data.aws_iam_policy_document.eks_nodes_role.json
}

resource "aws_iam_role_policy_attachment" "cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes_roles.name
}

resource "aws_iam_role_policy_attachment" "node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes_roles.name
}

resource "aws_iam_role_policy_attachment" "ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes_roles.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_nodes_roles.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.eks_nodes_roles.name
}

data "aws_iam_policy_document" "csi_driver" {
  version = "2012-10-17"

  statement {

    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = [
      aws_kms_key.eks.arn
    ]

  }

}

resource "aws_iam_policy" "csi_driver" {
  name        = join("-", ["policy", var.cluster_name, var.environment, "csi-driver"])
  path        = "/"
  description = var.cluster_name

  policy = data.aws_iam_policy_document.csi_driver.json
}

resource "aws_iam_policy_attachment" "csi_driver" {
  name = "aws_load_balancer_controller_policy"

  roles = [aws_iam_role.eks_nodes_roles.name]

  policy_arn = aws_iam_policy.csi_driver.arn
}

data "aws_iam_policy_document" "nodes_volume_create" {
  version = "2012-10-17"

  statement {

    effect = "Allow"
    actions = [
      "ec2:CreateVolume",
      "ec2:DeleteVolume",
      "ec2:DetachVolume",
      "ec2:AttachVolume",
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]

    resources = [
      "*"
    ]

  }
}

resource "aws_iam_policy" "nodes_volume_create" {
  name        = join("-", ["policy", var.cluster_name, var.environment, "nodes-volume-create"])
  path        = "/"
  description = var.cluster_name

  policy = data.aws_iam_policy_document.nodes_volume_create.json
}

resource "aws_iam_policy_attachment" "nodes_volume_create" {
  name = "nodes_volume_create"

  roles = [aws_iam_role.eks_nodes_roles.name]

  policy_arn = aws_iam_policy.nodes_volume_create.arn
}

## CLUSTER

data "aws_iam_policy_document" "eks_cluster_role" {

  version = "2012-10-17"

  statement {

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "eks.amazonaws.com",
        "eks-fargate-pods.amazonaws.com"
      ]
    }

  }

}

resource "aws_iam_role" "eks_cluster_role" {
  name               = join("-", ["role", var.cluster_name, var.environment, "eks-cluster"])
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_role.json
}

resource "aws_iam_role_policy_attachment" "eks-cluster-cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

## KARPENTER CONTROLLER

# data "aws_iam_policy_document" "karpenter_controller_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:karpenter:karpenter"]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.eks.arn]
#       type        = "Federated"
#     }
#   }
# }

# resource "aws_iam_role" "karpenter_controller" {
#   assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume_role_policy.json
#   name               = join("-", ["role", var.cluster_name, var.environment, "karpenter"])
# }

# resource "aws_iam_policy" "karpenter_controller" {
#   policy = file("karpenter/karpenter-controller-trust-policy.json")
#   name   = join("-", ["policy", var.cluster_name, var.environment, "karpenter"])
# }

# resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
#   role       = aws_iam_role.karpenter_controller.name
#   policy_arn = aws_iam_policy.karpenter_controller.arn
# }

# resource "aws_iam_instance_profile" "karpenter" {
#   name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
#   role = aws_iam_role.eks_nodes_roles.name
# }

## LOKI / TEMPO

resource "aws_iam_policy" "loki_tempo_policy" {
  name        = "LokiTempoPolicy-${var.cluster_name}"
  description = "Permissions for Loki and Tempo to access S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowLokiandTempoBucketonK8s",
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:AbortMultipartUpload",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:GetObjectVersion",
          "s3:ListMultipartUploadParts",
          "s3:GetObjectTagging",
          "s3:PutObjectTagging"
        ],
        Resource = [
          "arn:aws:s3:::${var.loki_bucket_name}/*",
          "arn:aws:s3:::${var.loki_bucket_name}",
          "arn:aws:s3:::${var.tempo_bucket_name}/*",
          "arn:aws:s3:::${var.tempo_bucket_name}"
        ]
      }
    ]
  })
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:prometheus:loki-sa",
        "system:serviceaccount:prometheus:tempo-sa"
      ]
    }
  }
}

resource "aws_iam_role" "loki_tempo_service_account_role" {
  name = "CustomRoleTempoandLokionK8s-${var.cluster_name}"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "loki_tempo_policy_attachment" {
  role       = aws_iam_role.loki_tempo_service_account_role.name
  policy_arn = aws_iam_policy.loki_tempo_policy.arn
}

