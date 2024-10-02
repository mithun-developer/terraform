provider "aws" {
  region     = var.region
  access_key = var.accesskey
  secret_key = var.secretkey
}

/*create VPC */

resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/20"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

/*create public subnet */

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id

  count      = length(var.cidrs)
  cidr_block = var.cidrs[count.index]

  tags = {
    Name = var.taggie[count.index]
  }
}


/*create private subnet */

# resource "aws_subnet" "private" {
#   vpc_id = aws_vpc.main.id


#   cidr_block = "192.168.2.0/24"


# }

/*create Internet gateway */

resource "aws_internet_gateway" "internetgateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}


/*create elastic ip  Routing table */
resource "aws_eip" "elasticip" {

  domain = "vpc"
}


/*create NAT gateway */

resource "aws_nat_gateway" "NATgateway" {
  allocation_id = aws_eip.elasticip.id
  subnet_id     = "192.168.2.0/24"

  tags = {
    Name = "NAT"
  }
}

/*create public Routing table */

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internetgateway.id
  }

  tags = {
    Name = "public_Routetable"
  }
}

/*create private Routing table */


resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "192.168.2.0/24"
    gateway_id = aws_nat_gateway.NATgateway.id
  }

  tags = {
    Name = "private_Routetable"
  }
}

/*Attach  Routing table to subnet */


resource "aws_route_table_association" "a" {
  subnet_id      = "192.168.1.0/24"
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = "192.168.2.0/24"
  route_table_id = aws_route_table.private_rt.id
}



/*create security group */

resource "aws_security_group" "SG4" {
  name        = "allow_tls"
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
    from_port   = 80
    to_port     = 443
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "SG4"
  }
}



/*create EC2 instance */

resource "aws_instance" "web" {
  ami               = var.ami
  for_each          = local.server
  instance_type     = each.value.instance_type
  availability_zone = each.value.availability_zone

  security_groups = [aws_security_group.SG4.id]

  tags = {
    Name = each.value.tags.Name
  }
}


/*create DB instance*/

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "db_cred"
}


locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}

resource "aws_db_instance" "mydb" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = local.db_creds.username
  password             = local.db_creds.password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  db_subnet_group_name = "192.168.2.0/24"
}
