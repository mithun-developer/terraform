provider "aws" {
  region     = var.region
  access_key = var.accesskey
  secret_key = var.secretkey
}
/*launch EC2*/
resource "aws_instance" "web" {
  ami                    = var.ami
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.sg3.id]

  key_name = "MithunSSH" # providing key pair


  # providing user data
  user_data = <<-EOF
              #!/bin/bash
              sudo su -
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<html><body><h1>Hello, World</h1></body></html>" > /var/www/html/index.html
              systemctl restart httpd
              EOF

  tags = {
    Name = "Webserver"
  }

}

/*Creating security group for EC2*/

resource "aws_security_group" "sg3" {


  name        = "sg3"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "SG3"
  }
}



