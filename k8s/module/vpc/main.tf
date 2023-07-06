resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags       = merge("${var.tags}", { Name = "${var.name}" })
}

resource "aws_subnet" "public_sn" {
  count = length("${var.public_subnets}")

  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}${var.az[count.index]}"
  cidr_block        = var.public_subnets[count.index]

  tags = merge("${var.tags}", { Name = "${var.name}-Public-sn-${var.az[count.index]}" })
}


resource "aws_subnet" "private_sn" {
  count = length("${var.private_subnets}")

  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}${var.az[count.index]}"
  cidr_block        = var.private_subnets[count.index]

  tags = merge("${var.tags}", { Name = "${var.name}-Private-sn-${var.az[count.index]}" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge("${var.tags}", { Name = "${var.name}-IGW" })
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge("${var.tags}", { Name = "${var.name}-public_route_table" })
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = merge("${var.tags}", { Name = "${var.name}-private_route_table" })
}

resource "aws_route_table_association" "rt_association_pb_sn" {
  count = length("${var.public_subnets}")

  subnet_id      = aws_subnet.public_sn.*.id[count.index]
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "rt_association_pv_sn" {
  count = length("${var.private_subnets}")

  subnet_id      = aws_subnet.private_sn.*.id[count.index]
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_eip" "nat_eip" {
  vpc = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "bastion_eip" {
  instance = var.bastion_id
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_sn[0].id
  tags          = merge("${var.tags}", { Name = "${var.name}-ngw" })
}

resource "aws_security_group" "tf_sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = "sw-tf_sg"
  description = "Default SG"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge("${var.tags}", { Name = "${var.name}-SG" })
}

