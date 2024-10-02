provider "aws" {

  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key

}


# resource "aws_instance" "web" {
#   ami           = var.aws_instance
#   instance_type = "t2.micro"

#   tags = {
#     Name = "webserver"
#   }
# }



# resource "aws_instance" "web" {
#   ami           = lookup(var.amis, var.aws_region)
#   instance_type = "t2.micro"

#   provisioner "local-exec" {
#     command = "echo(aws_instance.web.private_ip)>>private_ips.txt"
#   }


#   tags = {
#     Name = "webserver"
#   }


# }
# output "ip" {
#   value = aws_instance.web.public_ip
# }

# resource "aws_vpc" "mainvpc" {
#   cidr_block = "10.1.0.0/16"
# }

# resource "aws_default_security_group" "default" {
#   vpc_id = "vpc-30db3f4d"

#   ingress {
#     protocol  = -1
#     self      = true
#     from_port = 0
#     to_port   = 0
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


# terraform {
#   backend "s3" {
#     bucket = "suhabakups3bkt"
#     region = "us-east-1"
#     key    = "test"
#   }
# }


resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my_vpc"
  }
}


resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}


resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.example.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }

  tags = {
    Name = "example"
  }
}
