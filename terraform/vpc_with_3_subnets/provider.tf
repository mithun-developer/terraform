provider "aws" {
  region     = var.region
  access_key = var.accesskey
  secret_key = var.secretkey
}

/*Create VPC*/
resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/20"
  instance_tenancy = "default"

  tags = {
    Name = "my_vpc"
  }
}

/*Create 3 subnets at a time using count and for_each*/
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id

  /*using count*/

  #  count      = length(var.cidrs)
  #  cidr_block = var.cidrs[count.index]

  /*using for_each*/
  for_each   = tomap(var.cidrsmap)
  cidr_block = each.key






  tags = {
    Name = each.value

  }
}

/*need to check*/

output "aws_subnet" {
  value = values(aws_subnet.public)[*].id
}


/*create 2 Security groups using for_each*/


resource "aws_security_group" "sg2" {
  name        = "sg2"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.main.id # specify your VPC ID


  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.key
      to_port     = ingress.key
      protocol    = "tcp"
      cidr_blocks = ingress.value
      description = "Allow HTTP traffic"
    }

  }
}

/*spinning 2 ec2 instances at a time in multiple availability zones*/


# resource "aws_instance" "web" {
#   for_each          = local.servers
#   ami               = var.ami
#   instance_type     = each.value.instance_type
#   availability_zone = each.value.availability_zone


#   security_groups = [aws_security_group.sg2.id]
#   tags = {
#     Name = each.key
#   }
# }

//How to get them 2 different avaialbility zones
resource "aws_instance" "web" {
  for_each          = tomap(var.serverdetails)
  ami               = var.ami
  instance_type     = each.value
  availability_zone = each.value


  security_groups = [aws_security_group.sg2.id]
  tags = {
    Name = each.key
  }
}

