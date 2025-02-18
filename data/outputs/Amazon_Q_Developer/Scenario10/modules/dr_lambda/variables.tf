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
  default     = "dr-failover-handler"
}

variable "lambda_role_arn" {
  type        = string
  description = "ARN of the Lambda execution role"
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

variable "drs_configuration_id" {
  type        = string
  description = "ID of the DRS configuration"
}

variable "cross_region_role_arn" {
  type        = string
  description = "ARN of the cross-region access role"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for VPC configuration"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs for VPC configuration"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain Lambda logs"
  default     = 30
}

variable "log_encryption_key_arn" {
  type        = string
  description = "ARN of the KMS key for log encryption"
  default     = null
}

variable "enable_blue_green" {
  type        = bool
  description = "Enable blue/green deployment"
  default     = false
}

variable "eventbridge_rule_arn" {
  type        = string
  description = "ARN of the EventBridge rule"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
