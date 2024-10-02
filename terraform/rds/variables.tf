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

variable "cidrs" {

  type    = list(string)
  default = ["192.168.1.0/24", "192.168.2.0/24"]

}

variable "taggie" {

  type    = list(string)
  default = ["public", "private"]

}


variable "instancetype" {

  type = string


}

locals {

  server = {
    server-1 = {
      instance_type     = "t2.micro"
      availability_zone = "us-east-1a"

      tags = {
        Name = "WebServer"
      }
    }

    server-2 = {
      instance_type     = "t2.micro"
      availability_zone = "us-east-1b"

      tags = {
        Name = "DBServer"
      }
    }
  }
}
