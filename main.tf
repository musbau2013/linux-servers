variable "broker_name" {
  description = "Name of the MQ broker"
  type        = string
}

variable "engine_type" {
  description = "The type of broker engine (e.g., 'ActiveMQ' or 'RabbitMQ')"
  type        = string
  default     = "ActiveMQ"
}

variable "engine_version" {
  description = "The version of the broker engine"
  type        = string
}

variable "host_instance_type" {
  description = "The broker instance type"
  type        = string
  default     = "mq.t3.micro"
}

variable "deployment_mode" {
  description = "Deployment mode of the broker (SINGLE_INSTANCE or ACTIVE_STANDBY_MULTI_AZ)"
  type        = string
  default     = "SINGLE_INSTANCE"
}

variable "publicly_accessible" {
  description = "Indicates whether the broker is publicly accessible"
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "List of security group IDs associated with the broker"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs for the broker"
  type        = list(string)
}

variable "configuration_id" {
  description = "ID of the broker configuration"
  type        = string
  default     = null
}

variable "configuration_revision" {
  description = "Revision number of the broker configuration"
  type        = number
  default     = null
}

variable "enable_general_logs" {
  description = "Enable general logs for the broker"
  type        = bool
  default     = true
}

variable "enable_audit_logs" {
  description = "Enable audit logs for the broker"
  type        = bool
  default     = false
}

variable "username" {
  description = "Username for accessing the broker"
  type        = string
}

variable "password" {
  description = "Password for accessing the broker"
  type        = string
  sensitive   = true
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the broker"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vpc_id" {
  description = "VPC ID for the broker"
  type        = string
}

variable "tags" {
  description = "Tags to assign to the resources"
  type        = map(string)
  default     = {}
}

## main.tf

resource "aws_mq_broker" "this" {
  broker_name         = var.broker_name
  engine_type         = var.engine_type
  engine_version      = var.engine_version
  host_instance_type  = var.host_instance_type
  deployment_mode     = var.deployment_mode
  publicly_accessible = var.publicly_accessible

  security_groups = var.security_group_ids
  subnet_ids      = var.subnet_ids

  configuration {
    id       = var.configuration_id
    revision = var.configuration_revision
  }

  logs {
    general = var.enable_general_logs
    audit   = var.enable_audit_logs
  }

  user {
    username = var.username
    password = var.password
  }

  tags = var.tags
}

resource "aws_security_group" "mq_sg" {
  name_prefix = "${var.broker_name}-mq-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5671
    to_port     = 5671
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

output "mq_broker_arn" {
  value = aws_mq_broker.this.arn
}


output "broker_id" {
  description = "ID of the MQ broker"
  value       = aws_mq_broker.this.id
}

output "broker_arn" {
  description = "ARN of the MQ broker"
  value       = aws_mq_broker.this.arn
}

output "security_group_id" {
  description = "ID of the security group for the broker"
  value       = aws_security_group.mq_sg.id
}



# ---

# Amazon MQ Terraform Module

This module creates an Amazon MQ broker along with its associated security group and logging configurations.

## Usage

```hcl
module "mq_broker" {
  source               = "./amazon-mq"
  broker_name          = "example-broker"
  engine_type          = "ActiveMQ"
  engine_version       = "5.16.2"
  host_instance_type   = "mq.t3.micro"
  deployment_mode      = "SINGLE_INSTANCE"
  publicly_accessible  = false
  vpc_id               = "vpc-123456"
  subnet_ids           = ["subnet-123456", "subnet-654321"]
  security_group_ids   = []
  username             = "admin"
  password             = "secure-password"
  allowed_cidr_blocks  = ["192.168.1.0/24"]
  tags                 = {
    Environment = "dev"
    Project     = "AmazonMQSetup"
  }
}
