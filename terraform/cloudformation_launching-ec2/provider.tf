provider "aws" {
  region     = var.region
  secret_key = var.secret_key
  access_key = var.access_key

}


//launching ec2 instance using cloudformation template 

resource "aws_cloudformation_stack" "ec2_stack" {
  name          = "EC2ViaCloudFormation"
  template_body = file("ec2.yaml") # Load local template file

  # Optional parameters (if your template accepts them)
  # parameters = {
  #   KeyName = "my-key"
  # }

  capabilities = ["CAPABILITY_NAMED_IAM"]
}
