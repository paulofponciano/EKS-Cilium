## VPC

resource "aws_vpc" "cluster_vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = join("-", [var.cluster_name, var.environment, "vpc", var.aws_region])
    Project   = "${var.project}"
    Terraform = true
  }
}

## PRIVATE SUBNETS

resource "aws_subnet" "private_subnet_az1" {
  vpc_id     = aws_vpc.cluster_vpc.id
  cidr_block = var.private_subnet_az1_cidr

  availability_zone = var.az1

  tags = {
    Name                                        = join("-", [var.cluster_name, var.environment, "private", var.az1]),
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    Project                                     = "${var.project}"
    Terraform                                   = true
    "karpenter.sh/discovery"                    = "true"
  }
}

resource "aws_subnet" "private_subnet_az2" {
  vpc_id     = aws_vpc.cluster_vpc.id
  cidr_block = var.private_subnet_az2_cidr

  availability_zone = var.az2

  tags = {
    Name                                        = join("-", [var.cluster_name, var.environment, "private", var.az2]),
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    Project                                     = "${var.project}"
    Terraform                                   = true
    "karpenter.sh/discovery"                    = "true"
  }
}

resource "aws_route_table_association" "private_az1" {
  subnet_id      = aws_subnet.private_subnet_az1.id
  route_table_id = aws_route_table.nat_az1.id
}

resource "aws_route_table_association" "private_az2" {
  subnet_id      = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.nat_az1.id
}

## PUBLIC SUBNETS

resource "aws_subnet" "public_subnet_az1" {
  vpc_id = aws_vpc.cluster_vpc.id

  cidr_block              = var.public_subnet_az1_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.az1

  tags = {
    Name                                        = join("-", [var.cluster_name, var.environment, "public", var.az1]),
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    Project                                     = "${var.project}"
    Terraform                                   = true
  }
}

resource "aws_subnet" "public_subnet_az2" {
  vpc_id = aws_vpc.cluster_vpc.id

  cidr_block              = var.public_subnet_az2_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.az2

  tags = {
    Name                                        = join("-", [var.cluster_name, var.environment, "public", var.az2]),
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    Project                                     = "${var.project}"
    Terraform                                   = true
  }
}

resource "aws_route_table_association" "public_az1" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.igw_route_table.id
}

resource "aws_route_table_association" "public_az2" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.igw_route_table.id
}

## IGW

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.cluster_vpc.id

  tags = {
    Name      = join("-", [var.cluster_name, var.environment, "igw", var.aws_region])
    Project   = "${var.project}"
    Terraform = true
  }
}

resource "aws_route_table" "igw_route_table" {
  vpc_id = aws_vpc.cluster_vpc.id

  tags = {
    Name      = join("-", [var.cluster_name, var.environment, "public-rtb"])
    Project   = "${var.project}"
    Terraform = true
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.igw_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

## NGW

resource "aws_eip" "vpc_iep_1" {
  vpc = true
  tags = {
    Name      = join("-", [var.cluster_name, var.environment, "eip-ngw", var.az1])
    Project   = "${var.project}"
    Terraform = true
  }
}

resource "aws_nat_gateway" "nat_az1" {
  allocation_id = aws_eip.vpc_iep_1.id
  subnet_id     = aws_subnet.public_subnet_az1.id

  tags = {
    Name      = join("-", [var.cluster_name, var.environment, "ngw", var.az1])
    Project   = "${var.project}"
    Terraform = true
  }
}

resource "aws_route_table" "nat_az1" {
  vpc_id = aws_vpc.cluster_vpc.id

  tags = {
    Name      = join("-", [var.cluster_name, var.environment, "private-rtb", var.az1])
    Project   = "${var.project}"
    Terraform = true
  }
}

resource "aws_route" "nat_access_az1" {
  route_table_id         = aws_route_table.nat_az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_az1.id
}
