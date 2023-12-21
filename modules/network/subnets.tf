resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr, 2, 0)
  availability_zone = "eu-west-1a"

  tags = {
    Name = "plum-tree-public-a"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr, 2, 1)
  availability_zone = "eu-west-1a"

  tags = {
    Name = "plum-tree-private-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr, 2, 2)
  availability_zone = "eu-west-1b"

  tags = {
    Name = "plum-tree-public-b"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr, 2, 3)
  availability_zone = "eu-west-1b"

  tags = {
    Name = "plum-tree-private-a"
  }
}