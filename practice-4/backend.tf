terraform {
  backend "s3" {
    bucket = "practice-4te"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}