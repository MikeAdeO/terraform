provider "aws" {
  region                   = "us-east-1"
  shared_config_files      = ["/Users/USER/.aws/config"]
  shared_credentials_files = ["/Users/USER/.aws/credentials"]
}

resource "aws_instance" "my-first-server" {
  ami           = "ami-052efd3df9dad4825"
  instance_type = "t2.micro"
}
