# modules/ec2/main.tf

variable "ami_id" {
  type = string
  description = "AMI ID for the instance"
}

variable "instance_type" {
  type = string
  description = "Instance type"
}

variable "count" {
  type = number
  description = "Number of instances to create"
}

variable "name" {
  type = string
  description = "Base name for the instance"
}

variable "environment" {
  type = string
  description = "Environment (dev, prod)"
}


resource "aws_instance" "ec2" {
  for_each = toset(range(var.count))

  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = "${var.name}-${var.environment}-${each.key}"
    Environment = var.environment
    created_by  = "Terraform"
  }
}

output "instance_public_ips" {
  value = { for idx, instance in aws_instance.ec2 : "${var.name}-${var.environment}-${idx}" => instance.public_ip }
  description = "Public IPs of the EC2 instances"
}