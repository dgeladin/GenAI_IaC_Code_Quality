
# filename: variables.tf

variable "instance_ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "data_volume_size" {
  description = "Size of the EBS data volume in GB"
  type        = number
  default     = 100

  validation {
    condition     = var.data_volume_size >= 1 && var.data_volume_size <= 16384
    error_message = "EBS volume size must be between 1 and 16384 GB."
  }
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be launched"
  type        = string
}

# Note: common_tags variable was defined in previous step

variable "dr_subnet_id" {
  description = "Subnet ID in the DR region for DRS staging area"
  type        = string
}

# AWS provider configuration for DR region
provider "aws" {
  alias  = "dr_region"
  region = "us-east-1"
}

# Get current account ID
data "aws_caller_identity" "current" {}

# filename: cloudwatch_variables.tf

variable "recovery_automation_lambda_arn" {
  description = "ARN of the Lambda function that handles DR failover automation"
  type        = string
}

variable "notification_topic_arn" {
  description = "ARN of the SNS topic for failover notifications"
  type        = string
}

# filename: variables.tf

variable "backup_bucket_name" {
  description = "Name of the S3 bucket for DR backups"
  type        = string
  default     = "example-dr-backup-bucket"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.backup_bucket_name))
    error_message = "Bucket name must be lowercase alphanumeric characters or hyphens and cannot start or end with a hyphen."
  }
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Purpose     = "DisasterRecovery"
  }
}