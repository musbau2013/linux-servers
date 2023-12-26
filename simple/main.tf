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
  name = "ec2_sns_publish_role"

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
    name = "sns_publish_policy"
    
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = "sns:Publish",
          Effect = "Allow",
          Resource = aws_sns_topic.disk_space_topic.arn
        }
      ]
    })
  }
}

# Attach the AmazonSNSFullAccess policy to the IAM role (for SNS publishing permissions)
resource "aws_iam_policy_attachment" "ec2_sns_policy_attachment" {
  name       = "ec2_sns_attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess" # This policy grants SNS publishing permissions
  roles      = [aws_iam_role.ec2_role.name]
}

# Create an IAM instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_sns_publish_instance_profile"
  role = aws_iam_role.ec2_role.name
}

# Create an EC2 instance with the IAM instance profile
resource "aws_instance" "example_instance" {
  ami                  = "ami-0fc5d935ebf8bc3bc" # Replace with your desired AMI ID
  instance_type        = "t2.micro"
  key_name             = "newkey"                                           # Replace with your key pair name
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name # Attach the IAM instance profile to the EC2 instance
}

# Create an SNS topic for notifications
resource "aws_sns_topic" "disk_space_topic" {
  name = "disk_space_notifications"
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
  threshold           = 20 # Set your desired threshold for high CPU utilization
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
  threshold           = 35 # Set your desired threshold (e.g., 10% free space)
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
  threshold           = 15 # Set your desired threshold for high memory utilization
  alarm_description   = "Alarm when memory utilization exceeds 15%"
  alarm_actions       = [aws_sns_topic.disk_space_topic.arn]
  dimensions = {
    InstanceId = aws_instance.example_instance.id
  }

  treat_missing_data = "missing"
}

# resource "aws_instance" "imported" {
  
# }



