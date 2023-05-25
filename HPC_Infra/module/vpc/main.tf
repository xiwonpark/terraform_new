resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags       = merge("${var.tags}", { Name = "${var.name}" })
}

# <BLOCK TYPE> "<RESOURCE TYPE>" "<RESOURCE NAME>" {
# block body
# <IDENTIFIER> = <EXPRESSTIONS> # Argument
# }
#
# Indent is two Space
# Argument definition
## Key = Value
# Indent style diff
## terraform fmt -diff [file]

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

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_sn[0].id
  tags          = merge("${var.tags}", { Name = "${var.name}-ngw" })
}

resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge("${var.tags}", { Name = "${var.name}-vpn" })
}

data "aws_acm_certificate" "aws_cert" {
  domain   = "ez-test.link"
  statuses = ["ISSUED"]
}

resource "aws_security_group" "default_sg" {
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

resource "aws_alb" "alb" {
  name               = "${var.name}-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.default_sg.id}"]
  subnets            = [aws_subnet.public_sn[0].id, aws_subnet.public_sn[1].id]

  tags = merge("${var.tags}", { Name = "${var.name}-ALB" })
}


resource "aws_alb_target_group" "target_group_awx" {
  name     = "${var.name}-tg-awx"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_alb_target_group" "target_group_vnc" {
  name     = "${var.name}-tg-vnc"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_alb_listener" "listener_awx" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.aws_cert.arn

  default_action {
    target_group_arn = aws_alb_target_group.target_group_awx.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "listener_vnc" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "8443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.aws_cert.arn

  default_action {
    target_group_arn = aws_alb_target_group.target_group_vnc.arn
    type             = "forward"
  }
}