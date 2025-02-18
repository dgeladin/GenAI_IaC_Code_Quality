# General Variables
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Network Variables
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

# Database Variables
variable "db_username" {
  description = "Username for the master DB user"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = null # Will be set by locals based on environment
}

variable "allocated_storage" {
  description = "Allocated storage in GiB"
  type        = number
  default     = null # Will be set by locals based on environment
}

variable "max_allocated_storage" {
  description = "Maximum storage limit for autoscaling"
  type        = number
  default     = 100
}

# Backup and Maintenance Variables
variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = null # Will be set by locals based on environment
}

variable "backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

# Security Variables
variable "use_custom_kms_key" {
  description = "Whether to use a custom KMS key for encryption"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

# Monitoring Variables
variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds"
  type        = number
  default     = 60
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days"
  type        = number
  default     = 7
}

# Migration Variables
variable "enable_migrations" {
  description = "Enable database migrations"
  type        = bool
  default     = true
}

variable "migration_timeout" {
  description = "Timeout for database migrations in seconds"
  type        = number
  default     = 300
}

# Tag Variables
variable "additional_tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
