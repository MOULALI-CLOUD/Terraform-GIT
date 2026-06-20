resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/18"

  tags = {
    Name = "Final11-vpc"
  }
}

resource "aws_subnet" "name" {
  vpc_id     = aws_vpc.name.id
  cidr_block = "10.0.1.0/26"

  tags = {
    Name = "Final11-subnet1"
  }
}