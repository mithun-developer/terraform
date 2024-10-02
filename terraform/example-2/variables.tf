variable "aws_region" {
  type = string

  default = "us-east-2"

}

# variable "aws_instance" {
#   type = string
# }

variable "access_key" {
  type = string
}


variable "secret_key" {
  type = string
}


variable "amis" {
  type = map(string)
  default = {
    "us-east-1" = "ami-0b0ea68c435eb488d"
    "us-east-2" = "ami-05803413c51f242b7"
    "us-west-1" = "ami-04a119c5b7ed4e7ad"
  }
}
