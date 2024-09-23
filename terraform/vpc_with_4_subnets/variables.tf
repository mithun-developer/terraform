

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
  default = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24", "192.168.4.0/24"]
}


variable "taggi" {
  type = map(any)
  default = {
    Name = "subnet-1"

  }
}

variable "ports" {
  type = map(any)
  default = {
    80  = ["0.0.0.0/0"]
    443 = ["0.0.0.0/0"]
  }
}




locals {
  servers = {
    server-1 = {

      instance_type     = "t2.micro"
      availability_zone = "us-east-1a"

      tags = {
        name = "webserver"

      }

    }
    server-2 = {

      instance_type     = "t2.micro"
      availability_zone = "us-east-1b"
      tags = {

        name = "Dbserver"
      }
    }

  }

}

variable "ami_created" {
  default = true
}

variable "taggie" {
  type = list(string)

  default = ["subnet-1", "subnet-2", "subnet-3", "subnet-4"]
}

variable "tagsonly" {
  type = map(any)
  default = {
    Name = ["subnet-1"]
    Name = ["subnet-2"]
    Name = ["subnet-3"]
    Name = ["subnet-4"]


  }
}


variable "instancetype" {

  type = string

}

variable "servertags" {

  type    = list(string)
  default = ["webserver", "DBserver"]
}

variable "zones" {

  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}





variable "enable_vpc" {
  default = false
}
