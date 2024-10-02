provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}


resource "aws_instance" "webserver" {
  ami           = var.amiid
  instance_type = "t2.micro"

  tags = {
    Name = "web"
  }
}

/*creating security group*/

# resource "aws_default_security_group" "default" {
#   vpc_id = var.vpc

#   ingress {
#     protocol  = -1
#     self      = true
#     from_port = 0
#     to_port   = 0
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


/* creating s3 bkt */

# resource "aws_s3_bucket" "bkt" {
#   bucket = var.bucket

#   tags = {
#     Name        = "My bucket"
#     Environment = "Dev"
#   }
# }

/*creating  kms keys*/

# resource "aws_kms_key" "mm" {}

# resource "aws_kms_alias" "mm" {
#   name          = "alias/my-key-alias"
#   target_key_id = aws_kms_key.mm.id
# }

/*Attaching kms key to s3 bucket */

# resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
#   bucket = aws_s3_bucket.bkt.id

#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = aws_kms_key.mm.arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }

/*creating ec2 instance and attaching EBS volume */

# resource "aws_volume_attachment" "ebs_att" {
#   device_name = "/dev/sdh"
#   volume_id   = aws_ebs_volume.example.id
#   instance_id = aws_instance.web.id
# }

# resource "aws_ebs_volume" "example" {
#   availability_zone = "us-east-1a"
#   size              = 8

#   tags = {
#     Name = "HelloWorld"
#   }
# }

# resource "aws_instance" "web" {
#   ami               = "ami-00beae93a2d981137"
#   availability_zone = "us-east-1a"
#   instance_type     = "t2.micro"

#   tags = {
#     Name = "HelloWorld"
#   }
# }


/*launch template*/

resource "aws_launch_template" "foo" {
  name = "my_tf_template"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 8
    }
  }

  ebs_optimized = true


  /* Instance id = ec2 instance id 
image id = ami id

*/


  iam_instance_profile {
    name = "myrole"
  }

  image_id = var.amiid





  instance_type = "t2.micro"



  key_name = "MithunSSH"



  network_interfaces {
    associate_public_ip_address = true
    security_groups             = ["sg-0002683e8f684ac36"]
  }

  # vpc_security_group_ids = ["sg-00dbc4f85e6b52395"]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }

  user_data = filebase64("${path.module}/files/userdata.sh")
}


/*Auto scaling group*/

resource "aws_autoscaling_group" "asg" {
  name                = "my_tf_asggroup"
  vpc_zone_identifier = ["subnet-e8a771c9"]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1


  launch_template {
    id      = aws_launch_template.foo.id
    version = "$Latest"
  }
}
