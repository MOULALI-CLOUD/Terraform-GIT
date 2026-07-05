


resource "aws_key_pair" "name" {
key_name   = "my-key"
public_key = file("C:\\Users\\dell\\.ssh\\id_ed25519.pub")
}


resource "aws_vpc" "PRO-VPC" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "PRO-SUBNET-1" {
  vpc_id            = aws_vpc.PRO-VPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.PRO-VPC.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.PRO-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.PRO-SUBNET-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "PRO-SG" {
  name        = "PRO-SG"
  description = "Security group for PRO-VPC"
  vpc_id      = aws_vpc.PRO-VPC.id

  ingress {
    from_port   = 22
    to_port     = 22
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


resource "aws_instance" "PRO-EC2" {
  ami           = "ami-06067086cf86c58e6" # Amazon Linux 2 AMI
  instance_type = "t3.small"
  subnet_id     = aws_subnet.PRO-SUBNET-1.id
  key_name      = aws_key_pair.name.key_name
  vpc_security_group_ids = [aws_security_group.PRO-SG.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > /var/www/html/index.html
              EOF

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("C:\\Users\\dell\\.ssh\\id_ed25519")
      host        = self.public_ip
      timeout     = "2m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "touch /home/ec2-user/File200.txt",
      "echo 'File created successfully' >> /home/ec2-user/File200.txt",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("C:\\Users\\dell\\.ssh\\id_ed25519")
      host        = self.public_ip
      timeout     = "2m"
    }
  }

  provisioner "local-exec" {
    command = "touch success.txt"
  }
}       
