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

/*Create public and private subnets*/
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.2.0/24"

  tags = {
    Name = "private"
  }
}

/*Create Internet Gateway*/
resource "aws_internet_gateway" "internetgateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "my_gate_way"
  }
}


/*Create elastic IP*/

resource "aws_eip" "elasticip" {
  domain = "vpc"
}



/*Create NAT Gateway*/

resource "aws_nat_gateway" "natgateway" {
  allocation_id = aws_eip.elasticip.id
  subnet_id     = aws_subnet.private.id

  tags = {
    Name = "NAT"
  }
}




/*Create public and private route tables*/
resource "aws_route_table" "pub_routetable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internetgateway.id
  }

  tags = {
    Name = "public-routetable"
  }
}


resource "aws_route_table" "pri_routetable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "192.168.2.0/24"
    gateway_id = aws_nat_gateway.natgateway.id
  }

  tags = {
    Name = "private-routetable"
  }
}

/*Subnet attaching to route table*/
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.pub_routetable.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.pri_routetable.id
}


/*Create security group for ec2*/

resource "aws_security_group" "sg2" {
  name        = "sg2"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.main.id # specify your VPC ID

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "sg2"
  }
}

/*Create Load Balancer */

resource "aws_lb" "alb" {
  name     = "mylb"
  internal = false

  load_balancer_type = "application"

  subnets = [aws_subnet.public.id, aws_subnet.private.id]



  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.id
  #   prefix  = "test-lb"
  #   enabled = true
  # }

  tags = {
    Environment = "test"
  }
}


/*Creating target group*/
resource "aws_lb_target_group" "app_tg" {
  name        = "app-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id


  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "app_tg"
  }
}

/*Creating ALB listener*/

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}


/*creating launch configuration*/

resource "aws_launch_configuration" "as_conf" {
  name_prefix     = "terraform-lc-example-"
  image_id        = var.ami
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.sg2.id]


  associate_public_ip_address = true
  key_name                    = "MithunSSH"



  lifecycle {
    create_before_destroy = true
  }


}


# /*creating auto scaling group*/

resource "aws_autoscaling_group" "bar" {
  name                 = "terraform-asg-example"
  launch_configuration = aws_launch_configuration.as_conf.name
  min_size             = 1
  max_size             = 2


  vpc_zone_identifier = [aws_subnet.public.id, aws_subnet.private.id]
  lifecycle {
    create_before_destroy = true
  }
}


/*create DB instance*/

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}
