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




  /*creating life cycle rule on S3 bucket */
  # lifecycle_rule {
  #   id      = "transition_rule"
  #   enabled = true

  #   transition {
  #     days          = 30
  #     storage_class = "INTELLIGENT_TIERING"
  #   }

  #   expiration {
  #     days = 365
  #   }

  #   noncurrent_version_expiration {
  #     days = 90
  #   }
  # }
}






/*S3 bucket Transfer acceleration*/
resource "aws_s3_bucket_accelerate_configuration" "accelerate" {
  bucket = aws_s3_bucket.Webbucket.id
  status = "Enabled"
}


/*S3 bucket Access logging*/
resource "aws_s3_bucket_logging" "logging" {
  bucket = aws_s3_bucket.Webbucket.id

  target_bucket = aws_s3_bucket.Webbucket.id
  target_prefix = "log/"
}

/*Enable versioning to S3 */
resource "aws_s3_bucket_versioning" "versioning_1" {
  bucket = var.bucket
  versioning_configuration {
    status = "Enabled"
  }
}




/*Uploading object to S3 */

# resource "aws_s3_object" "object" {
#   bucket = var.bucket


#   key    = var.key
#   source = "${path.module}/S3_bkt_files/list1.txt"

# }

/* KMS encryption*/

# resource "aws_kms_key" "a" {}

# resource "aws_kms_alias" "a" {
#   name          = "alias/my-key-alias"
#   target_key_id = aws_kms_key.a.key_id
# }

/*Attaching kms key to s3 bucket */



# resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
#   bucket = aws_s3_bucket.Webbucket.id

#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = aws_kms_key.a.arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }


resource "aws_s3_bucket_lifecycle_configuration" "my_bucket_lifecycle" {
  bucket = aws_s3_bucket.Webbucket.id

  rule {
    id     = "my-lifecycle-rule" # Give your rule a unique ID
    status = "Enabled"           # Set to "Disabled" to turn off the rule

    expiration {
      days = 30 # Number of days after which the objects will expire
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA" # Move to Infrequent Access storage class after 30 days
    }

    noncurrent_version_expiration {
      noncurrent_days = 365 # Expire non-current object versions after 365 days
    }
  }

}
