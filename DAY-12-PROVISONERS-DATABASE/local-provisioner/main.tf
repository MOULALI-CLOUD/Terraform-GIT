resource "aws_subnet" "DBSubnet-1" {
  vpc_id            = aws_vpc.DBVPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}
resource "aws_subnet" "DBSubnet-2" {
  vpc_id            = aws_vpc.DBVPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_route_table" "dbrouteTable" {
  vpc_id = aws_vpc.DBVPC.id
}
resource "aws_internet_gateway" "DBInternetGateway" {
  vpc_id = aws_vpc.DBVPC.id
}

resource "aws_security_group" "DBSecurityGroup" {
  name        = "DBSecurityGroup"
  description = "Allow MySQL traffic"
  vpc_id      = aws_vpc.DBVPC.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
    }
    ingress {
        from_port   = 0
        to_port     = 5000
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

resource "aws_db_subnet_group" "DBSubnetGroup" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.DBSubnet-1.id, aws_subnet.DBSubnet-2.id]
}

resource "aws_db_instance" "MySQLDB" {
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  identifier              = "mydatabase"

  db_name                 = "company_db"
  username                = "admin"
  password                = "password123"

  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = true

  vpc_security_group_ids  = [aws_security_group.DBSecurityGroup.id]
  db_subnet_group_name    = aws_db_subnet_group.DBSubnetGroup.name

  publicly_accessible     = true
}

resource "aws_vpc" "DBVPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_route_table_association" "dbrouteTableAssociation-1" {
  subnet_id      = aws_subnet.DBSubnet-1.id
  route_table_id = aws_route_table.dbrouteTable.id
}

resource "aws_route_table_association" "dbrouteTableAssociation-2" {
  subnet_id      = aws_subnet.DBSubnet-2.id
  route_table_id = aws_route_table.dbrouteTable.id
}

#Instance for testing the database connectivity
resource "aws_instance" "DBInstance" {
  ami           = "ami-06067086cf86c58e6"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.DBSubnet-1.id
  security_groups = [aws_security_group.DBSecurityGroup.name]
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install mysql-client -y
              sudo yum install -y mysql105-mariadb
              sudo mysql -h ${aws_db_instance.MySQLDB.address} -u admin -ppassword123 -e "SHOW DATABASES;"

              EOF

  tags = {
    Name = "DBInstance"
  }
}

 connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = aws_instance.DBInstance.public_ip
}