provider "aws" {
  region     = var.region
  access_key = var.accesskey
  secret_key = var.secretkey
}


/*S3 bucket creation*/
resource "aws_s3_bucket" "Webbucket" {
  bucket = var.bucket

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

/*Uploading object to S3 */

resource "aws_s3_object" "object" {
  bucket = var.bucket


  key    = var.key
  source = "${path.module}/S3_bkt_files/application.txt"

}

