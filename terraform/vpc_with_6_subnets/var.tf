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

variable "instancetype" {
  type = string
}

variable "cidr" {

  type = map(any)

  default = {
    "192.168.1.0/24" = "public-subnet-1"
    "192.168.2.0/24" = "private-subnet-1"
    "192.168.3.0/24" = "Global-subnet"
  }

}


variable "inst" {

  type = map(any)

  default = {
    instance1 = { ami = "ami-0195204d5dce06d99", az = "us-east-1a", type = "t2.micro", name = "webserver" }
    instance2 = { ami = "ami-0195204d5dce06d99", az = "us-east-1b", type = "t2.micro", name = "dbserver" }
    instance3 = { ami = "ami-0195204d5dce06d99", az = "us-east-1c", type = "t2.micro", name = "Global-server" }

  }

}


variable "cidrlist" {
  type    = list(string)
  default = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
}

variable "ports" {
  type = map(any)
  default = {
    80  = ["0.0.0.0/0"]
    443 = ["0.0.0.0/0"]
  }
}




variable "amis" {
  type    = list(string)
  default = ["ami-0195204d5dce06d99", "ami-0195204d5dce06d99", "ami-0195204d5dce06d99"]
}

variable "instances" {
  type    = list(string)
  default = ["t2.micro", "t2.micro", "t2.micro"]
}


variable "zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}


variable "instancetaggie" {
  type    = list(string)
  default = ["Webserver", "Dbserver", "Global-Server"]
}

variable "taggie" {
  type    = list(string)
  default = ["public-subnet-1", "private-subnet-1", "Global-subnet"]
}

locals {
  servers = {

    server1 = {
      ami               = "ami-0195204d5dce06d99"
      instance_type     = "t2.micro"
      availability_zone = "us-east-1a"
      tags = {
        name = "webserver"
      }
    }
    server2 = {

      ami               = "ami-0195204d5dce06d99"
      instance_type     = "t2.micro"
      availability_zone = "us-east-1b"

      tags = {
        name = "Dbserver"
      }

    }

  }

}

locals {
  cid = {
    cid1 = {
      cidr_block = "192.168.1.0/24"

      tags = {

        name = "Public"
      }
    }

    cid2 = {
      cidr_block = "192.168.2.0/24"

      tags = {

        name = "Private"
      }
    }
  }
}
