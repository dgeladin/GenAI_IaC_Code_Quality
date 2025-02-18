variable "environment" {
  type        = string
  description = "Environment name (e.g., prod, staging)"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Environment name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "source_server_id" {
  type        = string
  description = "ID of the source server to replicate"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for DRS resources"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs for DRS resources"
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS key for encryption"
}

variable "replication_instance_type" {
  type        = string
  description = "Instance type for replication servers"
  default     = "t3.small"
}

variable "recovery_instance_type" {
  type        = string
  description = "Instance type for recovery instances"
  default     = "t3.medium"
}

variable "bandwidth_throttling" {
  type        = number
  description = "Bandwidth throttling in Mbps (0 for no throttling)"
  default     = 0
}

variable "replication_lag_threshold" {
  type        = number
  description = "Threshold for replication lag alarm (in seconds)"
  default     = 300
}

variable "sns_topic_arn" {
  type        = string
  description = "ARN of the SNS topic for notifications"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
