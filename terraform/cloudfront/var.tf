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

variable "aws_account_id" {
  type = number
}


variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  type        = string
}
