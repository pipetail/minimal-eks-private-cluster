// VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_range
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

// Private subnets
resource "aws_subnet" "private_0" {
  availability_zone = "${var.region}a"
  cidr_block        = var.private_subnets.0
  vpc_id            = aws_vpc.main.id

  tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

resource "aws_subnet" "private_1" {
  availability_zone = "${var.region}b"
  cidr_block        = var.private_subnets.1
  vpc_id            = aws_vpc.main.id

  tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

resource "aws_subnet" "private_2" {
  availability_zone = "${var.region}c"
  cidr_block        = var.private_subnets.2
  vpc_id            = aws_vpc.main.id

  tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

// route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "private_0" {
  subnet_id      = aws_subnet.private_0.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

// SG for endpoints
resource "aws_security_group" "base-endpoints" {
  name   = "vpc-endpoint-ec2"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "base-endpoints-443" {
  security_group_id = aws_security_group.base-endpoints.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = [
    var.private_subnets.0,
    var.private_subnets.1,
    var.private_subnets.2,
  ]
}

// endpoints
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    aws_route_table.private.id,
  ]
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_0.id,
    aws_subnet.private_1.id,
    aws_subnet.private_2.id,
  ]

  security_group_ids = [
    aws_security_group.base-endpoints.id,
  ]
}

resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_0.id,
    aws_subnet.private_1.id,
    aws_subnet.private_2.id,
  ]

  security_group_ids = [
    aws_security_group.base-endpoints.id,
  ]
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_0.id,
    aws_subnet.private_1.id,
    aws_subnet.private_2.id,
  ]

  security_group_ids = [
    aws_security_group.base-endpoints.id,
  ]
}






