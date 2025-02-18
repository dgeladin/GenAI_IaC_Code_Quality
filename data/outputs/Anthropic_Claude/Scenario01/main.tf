# Filename: main.tf

# Terraform version and provider configuration
terraform {
  required_version = ">= 1.8.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider configuration
provider "aws" {
  region = "us-east-1"
}

# Environment variable using current workspace
variable "environment" {
  description = "Current Terraform workspace environment"
  type        = string
  default     = "default"
  validation {
    condition     = contains(["default", "dev", "prod"], var.environment)
    error_message = "Environment must be one of: default, dev, prod"
  }
}

# Instance type map variable
variable "instance_type" {
  description = "EC2 instance types for different environments"
  type        = map(string)
  default = {
    default = "t2.micro"
    dev     = "t2.small"
    prod    = "t2.medium"
  }
}

# AMI ID variables
variable "windows_ami_id" {
  description = "AMI ID for Windows instances"
  type        = map(string)
  default = {
    default = "ami-0c55b159cbfafe1f0"
    dev     = "ami-0c55b159cbfafe1f1"
    prod    = "ami-0c55b159cbfafe1f2"
  }
}

variable "linux_ami_id" {
  description = "AMI ID for Linux instances"
  type        = map(string)
  default = {
    default = "ami-0747bdcabd34c712a"
    dev     = "ami-0747bdcabd34c712b"
    prod    = "ami-0747bdcabd34c712c"
  }
}

# Windows instances
resource "aws_instance" "windows_instances" {
  count         = terraform.workspace == "dev" ? 1 : (terraform.workspace == "prod" ? 2 : 0)
  ami           = var.windows_ami_id[terraform.workspace]
  instance_type = var.instance_type[terraform.workspace]

  tags = {
    Name        = "example-instance-${terraform.workspace}"
    created_by  = "Terraform"
    Environment = terraform.workspace
  }
}

# Linux instances
resource "aws_instance" "linux_instances" {
  count         = terraform.workspace == "dev" ? 1 : (terraform.workspace == "prod" ? 3 : 0)
  ami           = var.linux_ami_id[terraform.workspace]
  instance_type = var.instance_type[terraform.workspace]

  tags = {
    Name        = "example-instance-${terraform.workspace}"
    created_by  = "Terraform"
    Environment = terraform.workspace
  }
}

# Outputs
output "current_workspace" {
  value = terraform.workspace
}

output "selected_instance_type" {
  value = var.instance_type[terraform.workspace]
}

output "instance_ids" {
  value = concat(
    aws_instance.windows_instances[*].id,
    aws_instance.linux_instances[*].id
  )
}