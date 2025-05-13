provider "aws" {
  region     = var.region
  access_key = var.accesskey
  secret_key = var.secretkey
}


resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name                = "CPUUtilizationHigh"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "cpuutilization"
  namespace                 = "AWS/EC2/cpuutilization"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "Alarm when cpu utilization exceeds 80 percent"
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "disk_read_bytes_alarm" {
  alarm_name                = "diskreadbytesHigh"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "diskreadbytesHigh"
  namespace                 = "AWS/EC2/diskreadbytes"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "Alarm when disk read bytes exceeds 80 percent"
  insufficient_data_actions = []
}


resource "aws_cloudwatch_metric_alarm" "disk_write_bytes_alarm" {
  alarm_name                = "diskwritebytesHigh"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "diskwritebytesHigh"
  namespace                 = "AWS/EC2/diskwritebytes"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "Alarm when disk write bytes exceeds 80 percent"
  insufficient_data_actions = []
}
