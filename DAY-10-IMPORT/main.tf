resource "aws_instance" "ec2" {
    ami           = "ami-06067086cf86c58e6"
    instance_type = "t3.micro"
  tags = {
    Name = "Testing-servers"
  } 
}

resource "aws_vpc" "vpc" {
  cidr_block = "172.31.0.0/16"
  tags = {
    Name = "default"
  }

}