# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Use the environment variable to determine the instance type
locals {
  instance_type = var.instance_type[var.environment]
  windows_instance_count = {
    dev  = 1
    prod = 2
  }
  linux_instance_count = {
    dev  = 1
    prod = 3
  }
}

# Create Windows instances based on the environment
resource "aws_instance" "windows" {
  count         = lookup(local.windows_instance_count, var.environment, 0)
  ami           = var.ami_id_windows
  instance_type = local.instance_type

  tags = {
    Name       = "example-instance-${var.environment}-windows-${count.index}"
    Environment = var.environment
    created_by = "Terraform"
  }
}

# Create AWS Linux instances based on the environment
resource "aws_instance" "linux" {
  count         = lookup(local.linux_instance_count, var.environment, 0)
  ami           = var.ami_id_linux
  instance_type = local.instance_type

  tags = {
    Name       = "example-instance-${var.environment}-linux-${count.index}"
    Environment = var.environment
    created_by = "Terraform"
  }
}
