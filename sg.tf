## CLUSTER

resource "aws_security_group" "cluster_sg" {
  name   = join("-", [var.cluster_name, var.environment, "cluster-sg"])
  vpc_id = aws_vpc.cluster_vpc.id

  egress {
    from_port = 0
    to_port   = 0

    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = join("-", [var.cluster_name, var.environment, "cluster-sg"])
    Project   = "${var.project}"
    Terraform = true
  }

}

resource "aws_security_group_rule" "cluster_ingress_https" {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"

  security_group_id = aws_security_group.cluster_sg.id
  type              = "ingress"
}

resource "aws_security_group_rule" "nodeport_cluster" {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 30000
  to_port     = 32768
  description = "nodeport"
  protocol    = "tcp"

  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  type              = "ingress"
}

resource "aws_security_group_rule" "nodeport_cluster_udp" {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 30000
  to_port     = 32768
  description = "nodeport"
  protocol    = "udp"

  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  type              = "ingress"
}

## NODES

resource "aws_security_group" "cluster_nodes_sg" {
  name   = join("-", [var.cluster_name, var.environment, "nodes-sg"])
  vpc_id = aws_vpc.cluster_vpc.id

  egress {
    from_port = 0
    to_port   = 0

    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = join("-", [var.cluster_name, var.environment, "nodes-sg"])
    Project   = "${var.project}"
    Terraform = true
  }

}

resource "aws_security_group_rule" "nodeport" {
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 30000
  to_port     = 32768
  description = "nodeport"
  protocol    = "tcp"

  security_group_id = aws_security_group.cluster_nodes_sg.id
  type              = "ingress"
}
