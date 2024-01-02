# Configure the AWS provider
provider "aws" {
  region = "us-east-1" # Change to your desired AWS region
}

terraform {
  required_version = "~>1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Create an IAM role for the EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "ec2_sns_publish_role_monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  # Attach an inline policy to grant sns:Publish permission for the specific SNS topic
  inline_policy {
    name = "sns_publish_policy_monitoring"

    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action   = "sns:Publish",
          Effect   = "Allow",
          Resource = aws_sns_topic.disk_space_topic.arn
        }
      ]
    })
  }

  # Attach an inline policy to allow CloudWatch Logs access
  inline_policy {
    name = "cloudwatch_logs_policy_monitoring"

    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
          ],
          Effect   = "Allow",
          Resource = "*"
        }
      ]
    })
  }
}

# Attach the AmazonSNSFullAccess policy to the IAM role (for SNS publishing permissions)
resource "aws_iam_policy_attachment" "ec2_sns_policy_attachment" {
  name       = "ec2_sns_attachment1"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess" # This policy grants SNS publishing permissions
  roles      = [aws_iam_role.ec2_role.name]
}

# Create an IAM instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_sns_publish_instance_profile_monitoring"
  role = aws_iam_role.ec2_role.name
}

data "aws_ami" "example" {
  most_recent = true
  # owners           = ["self"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

# Create an EC2 instance with the IAM instance profile
resource "aws_instance" "example_instance" {
  ami                  = data.aws_ami.example.id
  instance_type        = "t2.medium"
  key_name             = "keypair"
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  tags = {
    Name = "monitoring"
  }

  root_block_device {
    volume_size = 20 # Size of the root volume in GB
  }
}

# Create an SNS topic for notifications
resource "aws_sns_topic" "disk_space_topic" {
  name = "disk_space_notifications_monitoring"
}

# Create an SNS subscription to send email notifications
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.disk_space_topic.arn
  protocol  = "email"
  endpoint  = "musbauinfo@gmail.com" # Replace with your email address
}

# Create CloudWatch Alarms to monitor CPU utilization
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  alarm_name          = "CPUUtilizationAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "Alarm when CPU utilization exceeds 20%"
  alarm_actions       = [aws_sns_topic.disk_space_topic.arn]
  dimensions = {
    InstanceId = aws_instance.example_instance.id
  }
}

# Create a CloudWatch Alarm to monitor disk space utilization
resource "aws_cloudwatch_metric_alarm" "disk_space_alarm" {
  alarm_name          = "DiskSpaceAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DiskSpaceUtilization"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 35
  alarm_description   = "Alarm when disk space utilization exceeds 35%"
  alarm_actions       = [aws_sns_topic.disk_space_topic.arn]
  dimensions = {
    InstanceId = aws_instance.example_instance.id
  }
  treat_missing_data = "missing"
}

# Create a CloudWatch Alarm to monitor memory utilization
resource "aws_cloudwatch_metric_alarm" "memory_utilization_alarm" {
  alarm_name          = "MemoryUtilizationAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 15
  alarm_description   = "Alarm when memory utilization exceeds 15%"
  alarm_actions       = [aws_sns_topic.disk_space_topic.arn]
  dimensions = {
    InstanceId = aws_instance.example_instance.id
  }
  treat_missing_data = "missing"
}

resource "aws_cloudwatch_log_group" "example_log_group" {
  name              = "example-log-group_monitoring" # Replace with your desired log group name
  retention_in_days = 7                   # Set the desired retention period (in days)
}

resource "aws_eip" "lb_monitoring" {
  instance = aws_instance.example_instance.id
  domain   = "vpc"
}

#### ksqm fzpc xpsb szlj
