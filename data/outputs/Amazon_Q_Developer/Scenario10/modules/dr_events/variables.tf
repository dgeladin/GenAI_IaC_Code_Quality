variable "environment" {
  type        = string
  description = "Environment name (e.g., prod, staging)"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Environment name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "primary_region" {
  type        = string
  description = "Primary region to monitor for health events"
}

variable "monitored_services" {
  type        = list(string)
  description = "List of AWS services to monitor for health events"
  default     = ["EC2", "RDS", "EBS"]
}

variable "severity_levels" {
  type        = list(string)
  description = "List of severity levels to monitor"
  default     = ["ERROR", "CRITICAL"]
}

variable "health_check_schedule" {
  type        = string
  description = "Schedule expression for health checks"
  default     = "rate(5 minutes)"
}

variable "sns_topic_arn" {
  type        = string
  description = "ARN of the SNS topic for notifications"
}

variable "lambda_function_arn" {
  type        = string
  description = "ARN of the Lambda function for DR failover"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
