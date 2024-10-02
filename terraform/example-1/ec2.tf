resource "aws_instance" "ec2" {
  ami           = "ami-0277155c3f0ab2930"
  instance_type = "t2.micro"

  tags = {
    name = "webserver"
  }
}



resource "aws_key_pair" "ssh_key" {
  key_name   = "MithunSSH_tf"
  public_key = file("C:/Users/Mithun/Downloads/MithunSSHpublic.pub") # Change the path to your SSH public key
}

resource "aws_cloudwatch_log_group" "log_grp" {

  name = "CPU_Utilization"

}


resource "aws_cloudwatch_log_metric_filter" "terminate_instances_filter" {
  name           = "TerminateInstancesFilter"
  log_group_name = aws_cloudwatch_log_group.log_grp.name

  pattern = "{ $.eventType = \"TerminateInstances\" }"

  metric_transformation {
    name      = "TerminateInstancesMetric"
    namespace = "CustomNamespace"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "stop_instance_alarm" {
  alarm_name          = "StopInstanceAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60 # 1 minute
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    InstanceId = aws_instance.ec2.id
  }

  # alarm_actions = [
  #   "arn:aws:automate:your_aws_region:ec2:stop"
  # ]
}

resource "aws_sns_topic" "email_subscription" {
  name = "stop_instance"
}


resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.email_subscription.arn
  protocol  = "email"
  endpoint  = "mithun.modali@gmail.com"
}
