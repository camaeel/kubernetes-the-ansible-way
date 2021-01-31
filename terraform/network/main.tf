resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(
    var.additional_tags,
    {
      Name = "main"
    },
  )
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  count      = length(var.aws_zones)
  availability_zone = var.aws_zones[count.index]
  map_public_ip_on_launch = true #for simplicity
  cidr_block = cidrsubnet(var.vpc_cidr, var.subnet_mask_length - parseint(split("/", var.vpc_cidr)[1], 10)  , count.index)

  tags = merge(
    var.additional_tags,
    {
      Name = "public-${count.index}"
    },
  )
}

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.main.id 
  tags = merge(
    var.additional_tags,
    {
      Name = "internet-gw"
    },
  )
} 

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {     
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }   
  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }   
  tags = merge(
    var.additional_tags,
    {
      Name = "public"
    },
  )
}

resource "aws_main_route_table_association" "public" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.public.id 
}

resource "aws_default_network_acl" "default-nacl" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 32768
    to_port    = 61000
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 600
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 6443
    to_port    = 6443
  }

  ingress {
    protocol   = "icmp"
    rule_no    = 700
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    var.additional_tags,
    {
      Name = "default-nacl"
    },
  )
}