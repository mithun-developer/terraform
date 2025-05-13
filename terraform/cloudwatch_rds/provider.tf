provider "aws" {
  region     = var.region
  access_key = var.accesskey
  secret_key = var.secretkey
}

data "aws_secretsmanager_secret_version" "secretsstore" {
  secret_id = "db_cred"
}


locals {
  db_cred = jsondecode(data.aws_secretsmanager_secret_version.secretsstore.secret_string)
}

/*create DB instance*/

resource "aws_db_instance" "mydb" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = local.db_creds.username
  password             = local.db_creds.password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  db_subnet_group_name = "192.168.2.0/24"
}


resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization" {
  alarm_name          = "rds-high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300" # 5 minutes
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.mydb.id
  }

  alarm_description = "This metric monitors RDS CPU utilization"
  alarm_actions     = [aws_sns_topic.alerts.arn]

  depends_on = [aws_db_instance.mydb]
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage_space" {
  alarm_name          = "rds-low-free-storage-space"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300" # 5 minutes
  statistic           = "Average"
  threshold           = "5000000000" # 5GB in bytes

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.mydb.id
  }

  alarm_description = "This metric monitors RDS Free Storage Space"
  alarm_actions     = [aws_sns_topic.alerts.arn]

  depends_on = [aws_db_instance.mydb]
}

resource "aws_cloudwatch_metric_alarm" "rds_database_connections" {
  alarm_name          = "rds-high-database-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300" # 5 minutes
  statistic           = "Average"
  threshold           = "100"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.mydb.id
  }

  alarm_description = "This metric monitors RDS Database Connections"
  alarm_actions     = [aws_sns_topic.alerts.arn]

  depends_on = [aws_db_instance.mydb]
}

resource "aws_sns_topic" "alerts" {
  name = "rds-alerts"
}

resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "mithun.modali@gmail.com"
}
