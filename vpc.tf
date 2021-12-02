resource "aws_vpc" "project_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Project VPC"
  }
}

resource "aws_internet_gateway" "project_int_gateway" {
  vpc_id = aws_vpc.project_vpc.id
  tags = {
    Name = "project_int_gateway"
  }
}

/*
  NAT Instance
*/
resource "aws_security_group" "nat" {
  name        = "security_group_vpc_nat"
  description = "Allow traffic to pass from the private subnet to the internet"
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

  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "NATSG"
  }
}

resource "aws_instance" "nat" {
  ami                         = "ami-0046c079820366dc3" # this is a special ami preconfigured to do NAT
  availability_zone           = var.availability_zone02
  instance_type               = "t2.micro"
  key_name                    = var.aws_key_name
  vpc_security_group_ids      = ["${aws_security_group.nat.id}"]
  subnet_id                   = aws_subnet.subnet_public01.id
  associate_public_ip_address = true
  source_dest_check           = false

  tags = {
    Name = "VPC NAT"
  }
}

/*
  Public Subnet
*/
resource "aws_subnet" "subnet_public01" {
  vpc_id                  = aws_vpc.project_vpc.id
  map_public_ip_on_launch = "true"
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone02

  tags = {
    Name = "Public Subnet"
  }
}
resource "aws_subnet" "subnet_public02" {
  vpc_id                  = aws_vpc.project_vpc.id
  map_public_ip_on_launch = "true"
  cidr_block              = var.public_subnet_cidr2
  availability_zone       = var.availability_zone01

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_route_table" "subnet_public01" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project_int_gateway.id
  }

  tags = {
    Name = "Public Subnet1"
  }
}

resource "aws_route_table_association" "subnet_public01" {
  subnet_id      = aws_subnet.subnet_public01.id
  route_table_id = aws_route_table.subnet_public01.id
}
resource "aws_route_table_association" "subnet_public02" {
  subnet_id      = aws_subnet.subnet_public02.id
  route_table_id = aws_route_table.subnet_public01.id
}

/*
  Private Subnet
*/
resource "aws_subnet" "subnet_privat01" {
  vpc_id                  = aws_vpc.project_vpc.id
  map_public_ip_on_launch = "false"
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.availability_zone01

  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_route_table" "subnet_privat01" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat.id
  }

  tags = {
    Name = "Private Subnet1"
  }
}

resource "aws_route_table_association" "subnet_privat01" {
  subnet_id      = aws_subnet.subnet_privat01.id
  route_table_id = aws_route_table.subnet_privat01.id
}


resource "aws_subnet" "subnet_privat02" {
  vpc_id                  = aws_vpc.project_vpc.id
  map_public_ip_on_launch = "false"
  cidr_block              = var.private_subnet_cidr2
  availability_zone       = var.availability_zone02

  tags = {
    Name = "Private Subnet2"
  }
}


resource "aws_route_table_association" "subnet_privat02" {
  subnet_id      = aws_subnet.subnet_privat02.id
  route_table_id = aws_route_table.subnet_privat01.id
}
