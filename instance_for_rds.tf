
resource "aws_security_group" "web" {
  name        = "security_group_vpc_web"
  description = "Allow incoming HTTP connections."

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 1000
    to_port     = 3000
    protocol    = "tcp"
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
    Name = "WebServerSG"
  }
}


resource "aws_instance" "web-rds" {
  ami                         = lookup(var.amis, var.aws_region)
  availability_zone           = var.availability_zone02
  instance_type               = "t2.micro"
  key_name                    = var.aws_key_name
  vpc_security_group_ids      = ["${aws_security_group.web.id}"]
  subnet_id                   = aws_subnet.subnet_public01.id
  associate_public_ip_address = true
  source_dest_check           = false


  tags = {
    Name = "RDS connection"
  }
}
