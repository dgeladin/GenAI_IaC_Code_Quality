variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "development"
}

variable "aws_region" {
  description = "AWS region for deploying resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"

  validation {
    condition     = length(var.ami_id) > 4 && substr(var.ami_id, 0, 4) == "ami-"
    error_message = "The ami_id value must be a valid AMI ID, starting with \"ami-\"."
  }
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size >= 20 && var.root_volume_size <= 100
    error_message = "Root volume size must be between 20 and 100 GB."
  }
}

variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to SSH to the instance"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Note: Should be restricted in production
}

variable "alarm_actions" {
  description = "List of ARNs to notify when CPU alarm is triggered"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs to notify when CPU alarm returns to OK state"
  type        = list(string)
  default     = []
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "development"
    Project     = "monitoring"
  }
}
