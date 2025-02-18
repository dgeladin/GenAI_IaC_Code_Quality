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
  description = "Primary AWS region to monitor"
}

variable "monitored_services" {
  type        = list(string)
  description = "List of AWS services to monitor"
  default     = ["EC2", "RDS", "EBS"]
}

variable "severity_levels" {
  type        = list(string)
  description = "List of severity levels to monitor"
  default     = ["ERROR", "CRITICAL"]
}

variable "instance_id" {
  type        = string
  description = "ID of the EC2 instance to monitor"
}

variable "enable_app_health_check" {
  type        = bool
  description = "Enable application health checks"
  default     = false
}

variable "health_check_schedule" {
  type        = string
  description = "Schedule expression for health checks"
  default     = "rate(5 minutes)"
}

variable "application_name" {
  type        = string
  description = "Name of the application to monitor"
  default     = ""
}

variable "alarm_actions" {
  type        = list(string)
  description = "List of ARNs to notify when alarm triggers"
  default     = []
}

variable "ok_actions" {
  type        = list(string)
  description = "List of ARNs to notify when alarm resolves"
  default     = []
}

variable "enable_webhook_notification" {
  type        = bool
  description = "Enable webhook notifications"
  default     = false
}

variable "webhook_url" {
  type        = string
  description = "Webhook URL for notifications"
  default     = ""
}

variable "webhook_auth_key" {
  type        = string
  description = "Authentication key for webhook"
  default     = ""
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
