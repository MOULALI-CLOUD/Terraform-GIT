resource "aws_vpc" "my-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "my-vpc"
    }
}
resource "aws_subnet" "my-subnet" {
    vpc_id     = aws_vpc.my-vpc.id
    cidr_block = "10.0.1.0/24"
    tags = {
        Name = "my-subnet"
    }
}

resource "aws_route_table" "my-route-table" {
    vpc_id = aws_vpc.my-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-igw.id
    }
}

resource "aws_internet_gateway" "my-igw" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
        Name = "my-igw"
    }
}

resource "aws_route_table_association" "my-route-table-association" {
    subnet_id      = aws_subnet.my-subnet.id
    route_table_id = aws_route_table.my-route-table.id
}

resource "aws_security_group" "my-sg" {
    name        = "my-sg"
    description = "My security group"
    vpc_id      = aws_vpc.my-vpc.id

    dynamic "ingress" {
  for_each = [22, 80, 443, 3306]

  content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_instance" "my-instance" {
    ami           = "ami-06067086cf86c58e6"
    instance_type = "t3.micro"
    subnet_id     = aws_subnet.my-subnet.id
  vpc_security_group_ids = [aws_security_group.my-sg.id]
    user_data = <<-EOF
                #!/bin/bash
                yum install -y nginx
                systemctl start nginx
                systemctl enable nginx
                EOF
    tags = {
        Name = "my-instance"
    }
}
