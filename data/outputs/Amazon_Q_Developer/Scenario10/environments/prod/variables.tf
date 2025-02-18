variable "environment" {
  type        = string
  default     = "prod"
  description = "Environment name"
}

variable "primary_region" {
  type        = string
  default     = "us-west-2"
  description = "AWS region for primary infrastructure"
}

variable "dr_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for DR infrastructure"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID in primary region"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID in primary region"
}

variable "dr_subnet_id" {
  type        = string
  description = "Subnet ID in DR region"
}

variable "dr_security_group_id" {
  type        = string
  description = "Security group ID in DR region"
}

variable "project_tags" {
  type        = map(string)
  description = "Common tags for all resources"
  default     = {
    Project       = "DR-Infrastructure"
    Classification = "critical"
    CostCenter    = "dr-operations"
    ManagedBy     = "terraform"
  }
}
