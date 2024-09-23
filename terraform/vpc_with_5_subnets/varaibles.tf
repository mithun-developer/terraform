variable "region" {
  type = string
}

variable "accesskey" {
  type = string
}

variable "secretkey" {
  type = string
}


variable "ami" {
  type = string
}


variable "multiami" {
  type = map(any)
  default = {

    ami           = "ami-0195204d5dce06d99"
    instance_type = "t2.micro"

  }
}




variable "instancetype" {
  type = string
}

variable "cidr" {

  type    = list(string)
  default = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24", "192.168.4.0/24", "192.168.5.0/24"]

}

variable "taggie" {
  type    = list(string)
  default = ["public-1", "public-2", "public-3", "private-1", "private-2"]
}


locals {
  server = {

    server1 = {
      ami               = "ami-0195204d5dce06d99"
      instance_type     = "t2.micro"
      availability_zone = "us-east-1a"

      tags = {
        Name = "WebServer"
      }
    }
    server2 = {
      ami               = "ami-0195204d5dce06d99"
      instance_type     = "t2.micro"
      availability_zone = "us-east-1b"

      tags = {
        Name = "DbServer"
      }

    }
  }
}


variable "cidrs" {

  type = map(any)
  default = {
    "192.168.1.0/24" = "public-1"
    "192.168.2.0/24" = "public-2"
    "192.168.3.0/24" = "public-3"
    "192.168.4.0/24" = "private-1"
    "192.168.5.0/24" = "private-2"
  }

}
