module "name" {
  source = "../Day-9-MODULES"

  count         = 2
  ami           = "ami-08f44e8eca9095668"
  instance_type = "t2.micro"
}