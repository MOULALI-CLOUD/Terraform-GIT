terraform {
  backend "s3" {
    bucket = "deploys3bucket-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}