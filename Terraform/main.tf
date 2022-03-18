
# Here we're simply setting the provider and creating a VPC to work from.
# Also create two security groups.
resource "aws_vpc" "securedevops" {
  cidr_block       = var.main_vpc_cidr
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
}
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.securedevops.id
}
resource "aws_subnet" "publicsubnets" {
  vpc_id     = aws_vpc.securedevops.id
  cidr_block = "${var.public_subnets}"
  tags = {
    Name = "Public"
  }
}
resource "aws_subnet" "privatesubnets" {
  vpc_id     = aws_vpc.securedevops.id
  cidr_block = "${var.private_subnets}"
  tags = {
    Name = "Private"
  }
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "securedevopsbook-group"
  subnet_ids = [aws_subnet.privatesubnets.id, aws_subnet.publicsubnets.id]

  tags = {
    Name = "My DB subnet group"
  }
}
resource "aws_route_table" "PublicRT" { 
  vpc_id = aws_vpc.securedevops.id
  route {
    cidr_block = "0.0.0.0/0" 
    gateway_id = aws_internet_gateway.IGW.id
  }
}
resource "aws_route_table" "PrivateRT" { 
  vpc_id = aws_vpc.securedevops.id
  route {
    cidr_block     = "0.0.0.0/0" 
    nat_gateway_id = aws_nat_gateway.NATgw.id
  }
}
resource "aws_route_table_association" "PublicRTassociation" {
  subnet_id      = aws_subnet.publicsubnets.id
  route_table_id = aws_route_table.PublicRT.id
}
resource "aws_route_table_association" "PrivateRTassociation" {
  subnet_id      = aws_subnet.privatesubnets.id
  route_table_id = aws_route_table.PrivateRT.id
}
resource "aws_eip" "nateIP" {
  vpc = true
}
resource "aws_nat_gateway" "NATgw" {
  allocation_id = aws_eip.nateIP.id
  subnet_id     = aws_subnet.publicsubnets.id
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow ALL inbound traffic"
  vpc_id      = aws_vpc.securedevops.id

  ingress {
    description      = "ALL from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all_traffic"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow Database traffic"
  vpc_id      = aws_vpc.securedevops.id
  tags = {
    Name = "allow_rds_traffic"
  }
}