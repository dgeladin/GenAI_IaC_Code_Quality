# Region Configuration
variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
  default     = "us-east-1"
}

# Project Configuration
variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "environment" {
  type        = string
  description = "Environment (e.g., dev, staging, prod)"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

variable "service_name" {
  type        = string
  description = "Name of the service running on the instances"
}

# VPC Configuration
variable "vpc_id" {
  type        = string
  description = "ID of the VPC where resources will be created"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block of the VPC"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the ASG"
}

# ASG Configuration
variable "min_size" {
  type        = number
  description = "Minimum size of the Auto Scaling Group"
  default     = 1
  validation {
    condition     = var.min_size > 0
    error_message = "Minimum size must be greater than 0"
  }
}

variable "max_size" {
  type        = number
  description = "Maximum size of the Auto Scaling Group"
  default     = 4
  validation {
    condition     = var.max_size >= var.min_size
    error_message = "Maximum size must be greater than or equal to minimum size"
  }
}

variable "desired_capacity" {
  type        = number
  description = "Desired capacity of the Auto Scaling Group"
  default     = 2
  validation {
    condition     = var.desired_capacity >= 1
    error_message = "Desired capacity must be greater than or equal to 1"
  }
}

# Instance Configuration
variable "instance_type" {
  type        = string
  description = "Primary instance type for the ASG"
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "Name of the SSH key pair to use for instances"
  default     = null
}

variable "volume_size" {
  type        = number
  description = "Size of the root volume in GB"
  default     = 20
  validation {
    condition     = var.volume_size >= 20
    error_message = "Volume size must be at least 20 GB"
  }
}

# Mixed Instances Configuration
variable "on_demand_base_capacity" {
  type        = number
  description = "Minimum amount of desired capacity that must be fulfilled by on-demand instances"
  default     = 1
}

variable "on_demand_percentage" {
  type        = number
  description = "Percentage of on-demand instances above base capacity"
  default     = 20
  validation {
    condition     = var.on_demand_percentage >= 0 && var.on_demand_percentage <= 100
    error_message = "On-demand percentage must be between 0 and 100"
  }
}

variable "spot_allocation_strategy" {
  type        = string
  description = "Strategy for allocating spot instances"
  default     = "capacity-optimized"
  validation {
    condition     = contains(["lowest-price", "capacity-optimized"], var.spot_allocation_strategy)
    error_message = "Spot allocation strategy must be either lowest-price or capacity-optimized"
  }
}

# Scaling Configuration
variable "cpu_target_value" {
  type        = number
  description = "Target value for CPU utilization"
  default     = 70
  validation {
    condition     = var.cpu_target_value > 0 && var.cpu_target_value <= 100
    error_message = "CPU target value must be between 1 and 100"
  }
}

variable "memory_target_value" {
  type        = number
  description = "Target value for memory utilization"
  default     = 70
  validation {
    condition     = var.memory_target_value > 0 && var.memory_target_value <= 100
    error_message = "Memory target value must be between 1 and 100"
  }
}

variable "memory_high_threshold" {
  type        = number
  description = "Threshold for high memory utilization alarm"
  default     = 80
  validation {
    condition     = var.memory_high_threshold > 0 && var.memory_high_threshold <= 100
    error_message = "Memory high threshold must be between 1 and 100"
  }
}

# Notification Configuration
variable "notification_email" {
  type        = string
  description = "Email address for ASG notifications"
  default     = ""
  validation {
    condition     = var.notification_email == "" || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.notification_email))
    error_message = "Invalid email address format"
  }
}

# Tag Configuration
variable "additional_tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources"
  default     = {}
}
