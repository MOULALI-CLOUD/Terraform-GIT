resource "aws_vpc" "VPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MAIN_VPC"
  }
}

resource "aws_subnet" "SUBNET" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public_SUBNET"
  }
}

resource "aws_subnet" "SUBNET2" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private_SUBNET"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "MAIN_IGW"
  }
}

resource "aws_route_table" "PUBLIC_ROUTE_TABLE" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "PUBLIC_ROUTE_TABLE"
  }
}

resource "aws_route" "PUBLIC_ROUTE" {
  route_table_id         = aws_route_table.PUBLIC_ROUTE_TABLE.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.IGW.id
}

resource "aws_route_table_association" "PUBLIC_ASSOCIATION" {
  subnet_id      = aws_subnet.SUBNET.id
  route_table_id = aws_route_table.PUBLIC_ROUTE_TABLE.id
}

resource "aws_route_table" "PRIVATE_ROUTE_TABLE" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "PRIVATE_ROUTE_TABLE"
  }
}

resource "aws_route_table_association" "PRIVATE_ASSOCIATION" {
  subnet_id      = aws_subnet.SUBNET2.id
  route_table_id = aws_route_table.PRIVATE_ROUTE_TABLE.id
}


resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.NAT_EIP.id
  subnet_id     = aws_subnet.SUBNET.id

  tags = {
    Name = "NAT_GATEWAY"
  }
}

resource "aws_route" "PRIVATE_ROUTE" {
  route_table_id         = aws_route_table.PRIVATE_ROUTE_TABLE.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.NAT.id
}

resource "aws_eip" "NAT_EIP" {
  domain = "vpc"
}


resource "aws_security_group" "SG" {
  name   = "RDS_SG"
  vpc_id = aws_vpc.VPC.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_subnet_group" "SUBNET_GROUP" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.SUBNET.id, aws_subnet.SUBNET2.id]
  tags = {
    Name = "RDS Subnet Group"
  }
}

resource "aws_db_instance" "RDS" {
  allocated_storage              = 20
  engine                          = "mysql"
  engine_version                  = "8.0"
  instance_class                  = "db.t3.micro"
  db_name                         = "MYDB_RDS"
  username                        = "admin"
  manage_master_user_password     = true
  parameter_group_name            = "default.mysql8.0"
  skip_final_snapshot             = true

  publicly_accessible             = true

  vpc_security_group_ids          = [aws_security_group.SG.id]
  db_subnet_group_name            = aws_db_subnet_group.SUBNET_GROUP.name
}
