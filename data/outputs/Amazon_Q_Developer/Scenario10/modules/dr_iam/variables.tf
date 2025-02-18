variable "environment" {
  type        = string
  description = "Environment name (e.g., prod, staging)"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Environment name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "primary_region" {
  type        = string
  description = "Primary AWS region"
}

variable "dr_region" {
  type        = string
  description = "DR AWS region"
}

variable "sns_topic_arn" {
  type        = string
  description = "ARN of the SNS topic for notifications"
}

variable "kms_key_arns" {
  type        = list(string)
  description = "List of KMS key ARNs"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
