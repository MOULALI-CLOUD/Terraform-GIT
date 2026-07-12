resource "aws_instance" "my_instance" {
  ami           = "ami-03ad130dfbe94dc2e"
  instance_type = "t3.small"
  tags = {
    Name = "MyInstance"
  }
}

resource "aws_s3_bucket" "name" {
  bucket = "my-uniqkjsdfbdsfbfbfddbjb"
  tags = {
    Name = "bsdjkbabdb"
  }
}

resource "aws_s3_object" "name" {
  bucket = aws_s3_bucket.name.bucket
  key    = "my-object"
  content = "Hello, World!"
}