variable "environment" {
  type        = string
  description = "Environment name (e.g., prod, staging)"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Environment name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket for DR backups"
  validation {
    condition     = can(regex("^[a-z0-9.-]+$", var.bucket_name))
    error_message = "Bucket name must contain only lowercase letters, numbers, dots, and hyphens."
  }
}

variable "primary_region" {
  type        = string
  description = "Primary AWS region"
}

variable "dr_region" {
  type        = string
  description = "DR AWS region"
}

variable "backup_retention_days" {
  type        = number
  description = "Number of days to retain backups"
  default     = 365
  validation {
    condition     = var.backup_retention_days >= 30
    error_message = "Backup retention must be at least 30 days."
  }
}

variable "alarm_actions" {
  type        = list(string)
  description = "List of ARNs to notify when backup errors occur"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
