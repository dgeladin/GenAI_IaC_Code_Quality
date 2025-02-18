# Filename: variables.tf
# Contains all variable declarations

variable "environment" {
  description = "Current Terraform workspace environment"
  type        = string
  default     = "default"
  validation {
    condition     = contains(["default", "dev", "prod"], var.environment)
    error_message = "Environment must be one of: default, dev, prod"
  }
}

variable "instance_type" {
  description = "EC2 instance types for different environments"
  type        = map(string)
  default = {
    default = "t2.micro"
    dev     = "t2.small"
    prod    = "t2.medium"
  }
}

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
