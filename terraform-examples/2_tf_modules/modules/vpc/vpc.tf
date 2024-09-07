# Create a VPC
resource "aws_vpc" "webVPC" {
  tags       = var.vpc_tags
  cidr_block = var.vpc_cidr
}

resource "aws_internet_gateway" "webIGW" {
  vpc_id = aws_vpc.webVPC.id
  tags = {
    Name    = join(" ", [var.project, " IGW"])
    Project = var.project
  }
}

//elastic IP in subnet1
resource "aws_eip" "webNatGatewayEIP1" {
  tags = {
    Name    = "webNatGatewayEIP1"
    Project = var.project
  }
}

//elastic IP in public subnet2
resource "aws_eip" "webNatGatewayEIP2" {
  tags = {
    Name    = "webNatGatewayEIP2"
    Project = var.project
  }
}


//network ACL for the VPC
resource "aws_network_acl" "publicACL" {
  vpc_id = aws_vpc.webVPC.id
  subnet_ids = [aws_subnet.webPublicSubnet1.id, aws_subnet.webPublicSubnet2.id]

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
      from_port   = var.ingress_rules[0]["port"]
      to_port     = var.ingress_rules[0]["port"]
      protocol    = var.ingress_rules[0]["protocol"]
      rule_no     = var.ingress_rules[0]["rule_no"]
      cidr_block   = var.ingress_rules[0]["cidr_blocks"][0]
      action      = "allow"
  }

   ingress {
      from_port   = var.ingress_rules[1]["port"]
      to_port     = var.ingress_rules[1]["port"]
      protocol    = var.ingress_rules[1]["protocol"]
      rule_no     = var.ingress_rules[1]["rule_no"]
      cidr_block   = var.ingress_rules[1]["cidr_blocks"][0]
      action      = "allow"
  }

  tags = {
    Name    = "publicACL"
    Project = var.project
  }
}


//define nat gateway in subnet1
resource "aws_nat_gateway" "webNatGateway1" {
  allocation_id = aws_eip.webNatGatewayEIP1.id
  subnet_id     = aws_subnet.webPublicSubnet1.id
  tags = {
    Name    = "webNatGateway1"
    Project = var.project
  }
}

//define nat gateway in public subnet2
resource "aws_nat_gateway" "webNatGateway2" {
  allocation_id = aws_eip.webNatGatewayEIP2.id
  subnet_id     = aws_subnet.webPublicSubnet2.id  //in video subnet 1 instead of subset 2
  tags = {
    Name    = "webNatGateway2"
    Project = var.project
  }
}

//define public subnet1
resource "aws_subnet" "webPublicSubnet1" {
  vpc_id            = aws_vpc.webVPC.id
  cidr_block        = var.public_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]
  tags = {
    Name    = "webPublicSubnet1"
    Project = var.project
  }
}

//define public subnet2
resource "aws_subnet" "webPublicSubnet2" {
  vpc_id            = aws_vpc.webVPC.id
  cidr_block        = var.public_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]
  tags = {
    Name    = "webPublicSubnet2"
    Project = var.project
  }
}

//define private subnet1
resource "aws_subnet" "webPrivateSubnet1" {
  vpc_id            = aws_vpc.webVPC.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]
  tags = {
    Name    = "webPrivateSubnet1"
    Project = var.project
  }
}

//define private subnet2
resource "aws_subnet" "webPrivateSubnet2" {
  vpc_id            = aws_vpc.webVPC.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]
  tags = {
    Name    = "webPrivateSubnet2"
    Project = var.project
  }
}

//Public route table
resource "aws_route_table" "webPublicRT" {
  vpc_id = aws_vpc.webVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webIGW.id
  }
  tags = {
    Name    = "webPublicRT"
    Project = var.project
  }
}

//Private route table
resource "aws_route_table" "webPrivateRT1" {
  vpc_id = aws_vpc.webVPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.webNatGateway1.id
  }
  tags = {
    Name    = "webPrivateRT1"
    Project = var.project
  }
}

resource "aws_route_table" "webPrivateRT2" {
  vpc_id = aws_vpc.webVPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.webNatGateway2.id
  }
  tags = {
    Name    = "webPrivateRT2"
    Project = var.project
  }
}

//public route table1
resource "aws_route_table_association" "webPublicRTAssociation1" {
  subnet_id      = aws_subnet.webPublicSubnet1.id
  route_table_id = aws_route_table.webPublicRT.id
}

//public route table2
resource "aws_route_table_association" "webPublicRTAssociation2" {
  subnet_id      = aws_subnet.webPublicSubnet2.id
  route_table_id = aws_route_table.webPublicRT.id
}