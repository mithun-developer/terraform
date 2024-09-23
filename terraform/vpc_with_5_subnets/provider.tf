provider "aws" {
  region     = var.region
  access_key = var.accesskey
  secret_key = var.secretkey
}

/*create VPC*/

resource "aws_vpc" "main" {

  cidr_block       = "192.168.0.0/20"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

/*create 5 subnets using count*/

# resource "aws_subnet" "public" {

#   count      = length(var.cidr)
#   vpc_id     = aws_vpc.main.id
#   cidr_block = var.cidr[count.index]

#   tags = {
#     count = length(var.taggie)
#     Name  = var.taggie[count.index]
#   }
# }

/*create 5 subnets using for each*/

resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id

  for_each   = tomap(var.cidrs)
  cidr_block = each.key

  tags = {
    //for_each = toset(var.taggie)
    Name = each.value
  }
}


/*Create 2 ec2 inctances at a time using for_each -----------  Not working*/
resource "aws_instance" "web" {

  for_each          = tomap(local.server)
  ami               = each.value.ami
  instance_type     = each.value.instance_type
  availability_zone = each.value.availability_zone

  security_groups = [aws_security_group.SG5.id]

  tags = {
    Name = each.value.tags.Name
  }
}


/*Create security group*/
resource "aws_security_group" "SG5" {
  name        = "SG5"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "SG5"
  }
}



