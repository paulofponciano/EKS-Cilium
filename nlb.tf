resource "aws_lb" "cilium_ingress" {
  name                             = join("-", [var.cluster_name, var.environment, "ingress"])
  internal                         = var.nlb_ingress_internal
  load_balancer_type               = var.nlb_ingress_type
  enable_cross_zone_load_balancing = var.enable_cross_zone_lb

  subnets = [
    aws_subnet.public_subnet_az1.id,
    aws_subnet.public_subnet_az2.id,
  ]

  tags = {
    Name                                        = join("-", [var.cluster_name, var.environment, "ingress"])
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_lb_target_group" "http" {
  name              = format("%s-http", var.cluster_name)
  port              = 30080
  protocol          = "TCP"
  vpc_id            = aws_vpc.cluster_vpc.id
  proxy_protocol_v2 = var.proxy_protocol_v2
}

resource "aws_lb_target_group" "https" {
  name              = format("%s-https", var.cluster_name)
  port              = 30443
  protocol          = "TCP"
  vpc_id            = aws_vpc.cluster_vpc.id
  proxy_protocol_v2 = var.proxy_protocol_v2
}

resource "aws_lb_listener" "ingress_443" {
  load_balancer_arn = aws_lb.cilium_ingress.arn
  port              = "443"
  #protocol          = "TCP"
   protocol        = "TLS"
   certificate_arn = "arn:aws:acm:us-east-2:310240692520:certificate/bfbfe3ce-d347-4c42-8986-f45e95e04ca1"
   alpn_policy     = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }
}

resource "aws_lb_listener" "ingress_80" {
  load_balancer_arn = aws_lb.cilium_ingress.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}
