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
  default = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
}

variable "ports" {
  type = map(any)
  default = {
    80 = ["0.0.0.0/0"]
    22 = ["0.0.0.0/0"]
  }
}

locals {

  servers = {
    server1 = {
      instance_type     = "t2.micro"
      availability_zone = "us-east-1a"
    }
    server2 = {
      instance_type     = "t2.micro"
      availability_zone = "us-east-1b"
    }
  }
}


variable "cidrsmap" {
  type = map(any)
  //default = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  default = {
    "192.168.1.0/24" = "subnet-1"
    "192.168.2.0/24" = "subnet-2"
    "192.168.3.0/24" = "subnet-3"

  }

}


variable "serverdetails" {
  type = map(any)
  default = {
    instance_type     = "t2.micro"
    availability_zone = "us-east-1a"
    name              = "webserver"
  }



}
