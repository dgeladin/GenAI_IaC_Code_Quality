variable "environment" {
  type        = string
  description = "Environment name (e.g., prod, staging)"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Environment name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "event_rule_name" {
  type        = string
  description = "Name of the CloudWatch event rule"
}

variable "lambda_function_arn" {
  type        = string
  description = "ARN of the Lambda function to trigger"
}

variable "alarm_actions" {
  type        = list(string)
  description = "List of ARNs to notify when DLQ contains messages"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
