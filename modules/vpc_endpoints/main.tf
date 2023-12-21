terraform {
  required_version = ">0.12.6"
}

data "aws_subnet" "subnet" {
  id = var.subnet_ids[0]
}

data "aws_vpc" "vpc" {
  id = data.aws_subnet.subnet.vpc_id
}

locals {
  region = element(split(":", data.aws_vpc.vpc.arn), 3)
  name_prefix = "plum-tree-foundation"
}

resource "aws_security_group" "interface_endpoint_security_group" {
  description = "Allow ingress traffic to VPC endpoint"
  name_prefix = "${local.name_prefix}-vpc-endpoint"
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    from_port = 443
    to_port = 443
    protocol = "tcp"
  }

  # SMTP SES port
  ingress {
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    from_port = 587
    to_port = 587
    protocol = "tcp"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_endpoint" "interface_endpoint" {
  for_each = toset(var.interface_service_names)

  private_dns_enabled = each.value == "s3" ? false : true
  security_group_ids = [aws_security_group.interface_endpoint_security_group.id]
  service_name = "com.amazonaws.${local.region}.${each.value}"
  subnet_ids = var.subnet_ids
  vpc_endpoint_type = "Interface"
  vpc_id = data.aws_vpc.vpc.id
}

resource "aws_vpc_endpoint" "gateway_endpoint" {
  for_each = toset(var.gateway_service_names)

  route_table_ids = var.route_table_ids
  service_name = "com.amazonaws.${local.region}.${each.value}"
  vpc_endpoint_type = "Gateway"
  vpc_id = data.aws_vpc.vpc.id
}
