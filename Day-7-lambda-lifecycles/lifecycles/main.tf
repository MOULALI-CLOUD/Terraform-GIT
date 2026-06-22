resource "aws_instance" "linux" {
  ami           = "ami-0521cb2d60cfbb1a6"
  instance_type = "t2.small"

  tags = {
    Name = "TESTING"
  }

  lifecycle {
    prevent_destroy       = true
    create_before_destroy = true
  }
}

resource "aws_instance" "windows" {
  ami           = "ami-09639480113b0df96"
  instance_type = "t3.nano"

  tags = {
    Name = "TESTING-windows"
  }

  lifecycle {
     create_before_destroy = true
  }
}