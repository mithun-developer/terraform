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

//--------------------------------------------------------------------------

/*create 5 subnets using count*/

# resource "aws_subnet" "subnets" {
#   vpc_id     = aws_vpc.main.id
#   count      = length(var.cidrlist)
#   cidr_block = var.cidrlist[count.index]

#   tags = {

#     Name = var.taggie[count.index]
#   }
# }


/*create 5 subnets using for each*/

# resource "aws_subnet" "subnets" {
#   vpc_id     = aws_vpc.main.id
#   for_each   = tomap(var.cidr)
#   cidr_block = each.key


#   tags = {

#     Name = each.value
#   }
# }


/*create 5 subnets using locals*/

# resource "aws_subnet" "subnets" {
#   vpc_id     = aws_vpc.main.id
#   for_each   = local.cidr
#   cidr_block = each.value.cidr_block


#   tags = {

#     Name = each.value.tags.name
#   }
# }


//--------------------------------------------------------------------------------


/*Create 2 ec2 inctances at a time using count*/

# resource "aws_instance" "web" {

#   count             = length(var.amis)
#   ami               = var.amis[count.index]
#   instance_type     = var.instances[count.index]
#   availability_zone = var.zones[count.index]

#   tags = {
#     Name = var.instancetaggie[count.index]
#   }
# }


/*Create 2 ec2 instances at a time using for_each */

resource "aws_instance" "web" {



  for_each = tomap(var.inst)

  ami               = each.value.ami
  instance_type     = each.value.type
  availability_zone = each.value.az

  tags = {
    Name = each.value.name
  }
}




/*Create 2 ec2 inctances at a time using locals*/

# resource "aws_instance" "web" {

#   for_each = local.servers

#   ami               = each.value.ami
#   instance_type     = each.value.instance_type
#   availability_zone = each.value.availability_zone

#   tags = {
#     Name = each.value.tags.name
#   }
# }


//--------------------------------------------------------------------------

/*Create security group using dynamic*/

resource "aws_security_group" "sg2" {

  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.key
      protocol    = "tcp"
      cidr_blocks = ingress.value
      to_port     = ingress.key
    }

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }


  tags = {
    Name = "sg2"
  }
}









