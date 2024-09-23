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




/*Create 4 subnets at a time using for_each*/
# resource "aws_subnet" "public" {
#   vpc_id   = aws_vpc.main.id
#   for_each = toset(var.cidrs)

#   cidr_block = each.value

#   tags = {

#     for_each = tomap(var.tagsonly)
#     Name     = each.value
#   }
# }








/*Create 4 subnets at a time using count*/
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  count  = length(var.cidrs)

  cidr_block = var.cidrs[count.index]

  tags = {
    Name = var.taggie[count.index]
  }
}

# output "chk" {

#   value    = values(aws_subnet.public)[*].id
# }

output "chk1" {

  value = var.servertags[*]
}



/*Create ec2 inctances at a time using for_each*/

# resource "aws_instance" "web" {
#   ami = var.ami

#   for_each          = local.servers
#   instance_type     = each.value.instance_type
#   availability_zone = each.value.availability_zone

#   tags = {
#     Name = each.value.tags.name


#   }
# }


/*Create ec2 inctances at a time using count*/


resource "aws_instance" "web" {

  count         = length(var.zones)
  ami           = var.ami
  instance_type = var.instancetype

  subnet_id = aws_subnet.public[count.index].id
  #vpc_security_group_ids = [for tag in var.servertags : tag == "webserver" ? aws_security_group.sg2.id : 0]

  vpc_security_group_ids = var.servertags[count.index] == "webserver" ? [aws_security_group.sg2.id] : [aws_security_group.sg3.id]



  // availability_zone = var.zones[count.index]

  tags = {
    Name = var.servertags[count.index]

  }
}


/*Create security groups with dynamic block using for_each*/

resource "aws_security_group" "sg2" {

  vpc_id = aws_vpc.main.id
  //name   = "sg2"

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.key
      protocol    = "tcp"
      cidr_blocks = ingress.value
      to_port     = ingress.key
    }
  }
  tags = {
    Name = "sg2"
  }
}


/*Create security groups with dynamic block using for_each*/

resource "aws_security_group" "sg3" {

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
  tags = {
    Name = "sg3"
  }
}

/*Creaing another VPC using if else condition*/

resource "aws_vpc" "DB_vpc" {
  count            = var.enable_vpc ? 1 : 0
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Enabled_vpc"
  }
}
