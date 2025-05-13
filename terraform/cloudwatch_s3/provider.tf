provider "aws" {
  region     = var.region
  access_key = var.accesskey
  secret_key = var.secretkey
}


resource "aws_cloudwatch_metric_alarm" "bucket_size" {
  alarm_name                = "terraform-bucketsize"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "bucketSizeBytes"
  namespace                 = "AWS/S3/listname"
  period                    = 86400
  statistic                 = "Average"
  threshold                 = 1000000000
  alarm_description         = "Alarm when bucket size exceeds 1 GB"
  insufficient_data_actions = []
}


resource "aws_cloudwatch_metric_alarm" "object_count" {
  alarm_name                = "terraform-objectcount"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "objectCount"
  namespace                 = "AWS/S3/listname"
  period                    = 86400
  statistic                 = "Average"
  threshold                 = 10000
  alarm_description         = "Alarm when object count exceeds 10000 objects"
  insufficient_data_actions = []
}


resource "aws_cloudwatch_metric_alarm" "numberOfRequests" {
  alarm_name                = "terraform-numberOfRequests"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "numberOfRequests"
  namespace                 = "AWS/S3/listname"
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1000
  alarm_description         = "Alarm when number of requests exceeds 1000 in 5 minutes"
  insufficient_data_actions = []
}


resource "aws_cloudwatch_metric_alarm" "numberOf4xxErrors" {
  alarm_name                = "terraform-numberOf4xxErrors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "numberOf4xxErrors"
  namespace                 = "AWS/S3/listname"
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 3
  alarm_description         = "Alarm when number of 400 Errors exceeds 3 in 5 minutes"
  insufficient_data_actions = []
}
