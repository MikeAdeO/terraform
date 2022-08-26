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

## AWS VPC
# resource "aws_vpc" "first-vpc" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     "Name" = "production"
#   }
  
# }

# # AWS SUBNET 1
# resource "aws_subnet" "subnet-1" {
#   vpc_id = aws_vpc.first-vpc.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     "Name" = "prod-subnet-1"
#   }
# }

# DEPLOY A SIMPLE SERVER
resource "aws_vpc" "production-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "production"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "production-internet-gateway" {
  vpc_id = aws_vpc.production-vpc.id
  
}

# Create a custom Route Table
resource "aws_route_table" "production-route-table" {
 vpc_id = aws_vpc.production-vpc

 route  {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.production-internet-gateway.id

 }

 route {
  ipv6_cidr_block = "::/0"
  egress_only_gateway_id = aws_internet_gateway.production-internet-gateway.id
 }

 tags = {
   "Name" = "production"
 }
  
}

# CREATE A SUBNET
resource "aws_subnet" "production-subnet-1" {
  vpc_id = aws_vpc.production-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "production-subnet"
  }
  
}

# Associate subnet with Route Table
resource "aws_route_table_association" "production-route-table-associate" {
  subnet_id = aws_subnet.production-subnet-1.id
  route_table_id = aws_route_table.production-route-table.id
  
}

# CREATE A SECURITY GROUP
resource "aws_security_group" "production-security-group" {
  name = "allow_web_traffic"
  description = "Allow TLS inbound traffic"
  vpc_id = aws_vpc.production-vpc.id

  ingress =  {
    description = "HTTPS"
    from_port = 443
    protocol = tcp
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress =  {
    description = "HTTP"
    from_port = 80
    protocol = tcp
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress =  {
    description = "SSH"
    from_port = 22
    protocol = tcp
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress = {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  } 

  tags = {
    "Name" = "allow_web"
  }
  
}

# CREATE A NETWORK INTERFACE WITH AN IP in the subnet that was created above

resource "aws_network_interface" "production-web-server-network-interface" {
  subnet_id = aws_subnet.production-subnet-1.id
  private_ip = ["10.0.1.50"]
  security_groups =  [aws_security_group.production-security-group]  
}

# Assign an elastic IP to the network interface created above
resource "aws_eip" "production-eip" {
  vpc = true
  network_interface = aws_network_interface.production-web-server-network-interface.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = aws_internet_gateway.production-internet-gateway
  
}

# Create Ubuntu Server
resource "aws_instance" "web-server-instance" {
  ami           = "ami-052efd3df9dad4825"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "main-key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.production-web-server-network-interface.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo your very first web server > /var/www/html/index.html'


  
}


