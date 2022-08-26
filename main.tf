provider "aws" {
  region                   = "us-east-1"
  shared_config_files      = ["/Users/USER/.aws/config"]
  shared_credentials_files = ["/Users/USER/.aws/credentials"]
}

# AWS EC2 INSTANCE
# resource "aws_instance" "my-first-server" {
#   ami           = "ami-052efd3df9dad4825"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "Ubuntu"
#   }
# }

# AWS VPC
resource "aws_vpc" "first-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "production"
  }
  
}

# AWS SUBNET 1
resource "aws_subnet" "subnet-1" {
  vpc_id = aws_vpc.first-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    "Name" = "prod-subnet-1"
  }
}


