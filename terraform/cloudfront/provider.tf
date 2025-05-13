provider "aws" {
  region     = var.region
  access_key = var.accesskey
  secret_key = var.secretkey
}

data "aws_caller_identity" "current" {}
resource "random_pet" "bucket_suffix" {
  length    = 2
  separator = "-"
}

// S3 bucket creation with random name

resource "aws_s3_bucket" "static_site" {
  bucket = "my-static-site-${random_pet.bucket_suffix.id}"
  //bucket        = "my-static-site-${data.aws_caller_identity.current.account_id}-${replace(timestamp(), ":", "")}-${random_pet.bucket_suffix.id}" // create bucket with time stamp
  force_destroy = true
}



# Enable Static Website Hosting

# resource "aws_s3_bucket_website_configuration" "website" {
#   bucket = aws_s3_bucket.static_site.bucket

#   index_document {
#     suffix = "index.html"
#   }
# }


# Upload index.html to S3

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.static_site.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"

}



#  Create Origin Access Control for CloudFront
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "S3-OAC-${aws_s3_bucket.static_site.bucket}"
  description                       = "OAC for private S3 static site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# allow_public_policy

resource "aws_s3_bucket_public_access_block" "allow_public_policy" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# S3 Bucket Policy for Public Read (not for production)
# resource "aws_s3_bucket_policy" "public_read" {
#   bucket = aws_s3_bucket.static_site.bucket

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect    = "Allow",
#       Principal = "*",
#       Action    = ["s3:GetObject"],
#       Resource  = "${aws_s3_bucket.static_site.arn}/*"
#     }]
#   })
# }

# CloudFront Distribution
resource "aws_cloudfront_distribution" "cdn" {

  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.static_site.bucket_regional_domain_name
    origin_id   = "s3-origin-${aws_s3_bucket.static_site.bucket}"

    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin-${aws_s3_bucket.static_site.bucket}"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "SecureStaticSite"
  }
}

# 🔒 S3 Bucket Policy allowing ONLY CloudFront OAC access
resource "aws_s3_bucket_policy" "allow_cf_oac" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "cloudfront.amazonaws.com"
      },
      Action   = "s3:GetObject",
      Resource = "${aws_s3_bucket.static_site.arn}/*",
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
        }
      }
    }]
  })
}

// cloudwatch to monitor - Request Rate , Low Cache Hit Ratio , High Latency

#  Alarm: Request Rate (High Traffic)
resource "aws_cloudwatch_metric_alarm" "high_request_rate" {
  alarm_name          = "CloudFront-High-RequestRate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Requests"
  namespace           = "AWS/CloudFront"
  period              = 60
  statistic           = "Sum"
  threshold           = 1000
  alarm_description   = "Triggered when CloudFront request rate exceeds 1000 requests per minute"
  dimensions = {
    DistributionId = var.cloudfront_distribution_id,
    Region         = "Global"
  }
}

# Alarm: Low Cache Hit Ratio
resource "aws_cloudwatch_metric_alarm" "low_cache_hit_ratio" {
  alarm_name          = "CloudFront-Low-CacheHitRatio"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CacheHitRate"
  namespace           = "AWS/CloudFront"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Triggered when Cache Hit Ratio drops below 70%"
  dimensions = {
    DistributionId = var.cloudfront_distribution_id,
    Region         = "Global"
  }
}

#  Alarm: High Latency
resource "aws_cloudwatch_metric_alarm" "high_latency" {
  alarm_name          = "CloudFront-High-Latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TotalTime"
  namespace           = "AWS/CloudFront"
  period              = 60
  statistic           = "Average"
  threshold           = 1.5 # in seconds
  alarm_description   = "Triggered when CloudFront response latency exceeds 1.5 seconds"
  dimensions = {
    DistributionId = var.cloudfront_distribution_id,
    Region         = "Global"
  }
}
