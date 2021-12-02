
resource "aws_security_group" "rds" {
  name        = "security_group_vpc_db"
  description = "Allow incoming database connections."

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.web.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "RDS_SG"
  }
}

resource "aws_db_subnet_group" "rds-subnet" {
  name       = "db subnet group"
  subnet_ids = [aws_subnet.subnet_privat01.id, aws_subnet.subnet_privat02.id]

  tags = {
    Name = "RDS subnet group"
  }
}

resource "aws_db_instance" "rds" {
  identifier             = var.rds_instance_identifier
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0.23"
  instance_class         = "db.t2.micro"
  name                   = var.database_name
  username               = var.database_user
  password               = var.database_password
  db_subnet_group_name   = aws_db_subnet_group.rds-subnet.id
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  skip_final_snapshot    = true
}

resource "aws_db_parameter_group" "mysql" {
  name   = "${var.rds_instance_identifier}-param-group"
  family = "mysql8.0"
  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}
