resource "aws_s3_bucket" "name" {
  bucket = "vfjvfvvv"
}
resource "aws_s3_object" "name" {
  bucket = aws_s3_bucket.name.bucket
  key    = "my-object"
  }

resource "aws_security_group" "name" {
  name        = "my-security-group"
  description = "My security group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
}