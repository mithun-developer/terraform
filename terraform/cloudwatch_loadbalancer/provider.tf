provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = ["vpc-30db3f4d"]
  }
}



/*Create alb*/

resource "aws_lb" "alb" {
  name               = "Alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg2.id]
  subnets            = data.aws_subnets.subnets.ids

  enable_deletion_protection = false

  tags = {
    Environment = "TEST"
  }
}

/*Create alb listener*/

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tgtgrp.arn
  }
}

/*Create target group*/

resource "aws_lb_target_group" "tgtgrp" {
  name     = "Alb-tgt-grp"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-30db3f4d"


  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "app_tg"
  }
}


/*create launch template*/

resource "aws_launch_template" "as_conf" {
  name          = "web_config"
  image_id      = var.ami
  instance_type = "t2.micro"
  user_data = base64encode(<<-EOF
        #!/bin/bash

########################################
##### USE THIS WITH AMAZON LINUX 2 #####
########################################

# get admin privileges
sudo su

# install httpd (Linux 2 version)
yum update -y
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
echo "Hello Worlds from $(hostname -f)" > /var/www/html/index.html
EOF
  )

  iam_instance_profile {
    name = "MithunEc2SSMRole"
  }
}



//create autoscaling group

resource "aws_autoscaling_group" "bar" {
  name                      = "foobar3-terraform-test"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = true
  vpc_zone_identifier       = data.aws_subnets.subnets.ids
  launch_template {
    id      = aws_launch_template.as_conf.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tgtgrp.arn]

}


/*Create security group for ec2*/

resource "aws_security_group" "sg2" {
  name        = "sg2"
  description = "Security group for EC2 instance"
  vpc_id      = "vpc-30db3f4d" # specify your VPC ID

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "sg2"
  }
}

# Auto Scaling Group Scaling Policies
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out-policy"
  autoscaling_group_name = aws_autoscaling_group.bar.name
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in-policy"
  autoscaling_group_name = aws_autoscaling_group.bar.name
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
}

# High CPU Utilization → Scale Out
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "HIGH CPU"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alarm when CPU exceeds 70%"
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.bar.name
  }
}

# Low CPU Utilization → Scale In
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "low-cpu-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "LOW CPU"
  period              = 60
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Alarm when CPU is below 30%"
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.bar.name
  }

}

# ALB Request Count Alarm Example 
resource "aws_cloudwatch_metric_alarm" "alb_high_requests" {
  alarm_name          = "alb-high-request-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 500
  alarm_description   = "High request count on ALB"
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]
  dimensions = {
    LoadBalancer = aws_lb.alb.arn_suffix
  }
}
