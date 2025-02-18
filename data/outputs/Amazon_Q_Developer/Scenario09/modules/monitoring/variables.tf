variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
}

# AWS Variables
variable "enable_aws_integration" {
  description = "Enable AWS integration with Datadog"
  type        = bool
  default     = true
}

variable "aws_account_id" {
  description = "AWS account ID for Datadog integration"
  type        = string
  default     = ""
}

variable "aws_integration_role_name" {
  description = "AWS IAM role name for Datadog integration"
  type        = string
  default     = "DatadogIntegrationRole"
}

variable "aws_instance_id" {
  description = "AWS EC2 instance ID to monitor"
  type        = string
}

variable "aws_region" {
  description = "AWS region where the instance is deployed"
  type        = string
}

# Azure Variables
variable "enable_azure_integration" {
  description = "Enable Azure integration with Datadog"
  type        = bool
  default     = true
}

variable "azure_tenant_name" {
  description = "Azure tenant name for Datadog integration"
  type        = string
  default     = ""
}

variable "azure_client_id" {
  description = "Azure client ID for Datadog integration"
  type        = string
  default     = ""
}

variable "azure_client_secret" {
  description = "Azure client secret for Datadog integration"
  type        = string
  default     = ""
  sensitive   = true
}

variable "azure_vm_name" {
  description = "Azure VM name to monitor"
  type        = string
}

variable "azure_resource_group" {
  description = "Azure resource group containing the VM"
  type        = string
}

variable "azure_location" {
  description = "Azure region where the VM is deployed"
  type        = string
}

# Monitoring Thresholds
variable "cpu_threshold_critical" {
  description = "Critical threshold for CPU usage"
  type        = number
  default     = 80
}

variable "cpu_threshold_warning" {
  description = "Warning threshold for CPU usage"
  type        = number
  default     = 70
}

variable "memory_threshold_critical" {
  description = "Critical threshold for memory usage"
  type        = number
  default     = 85
}

variable "memory_threshold_warning" {
  description = "Warning threshold for memory usage"
  type        = number
  default     = 75
}

variable "disk_threshold_critical" {
  description = "Critical threshold for disk usage"
  type        = number
  default     = 90
}

variable "disk_threshold_warning" {
  description = "Warning threshold for disk usage"
  type        = number
  default     = 80
}

# Notification Configuration
variable "notification_targets" {
  description = "Notification targets for alerts (e.g., @email.com)"
  type        = string
}

variable "additional_tags" {
  description = "Additional tags to add to monitors and dashboard"
  type        = list(string)
  default     = []
}
