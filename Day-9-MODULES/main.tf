resource "aws_instance" "EC2" {
  ami           = local.ami
  instance_type = local.instance_type
  tags = {
    Name = local.instance_name
  }
}