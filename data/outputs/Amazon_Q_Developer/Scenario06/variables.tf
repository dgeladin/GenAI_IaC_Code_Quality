# variables.tf

# General Configuration
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
}

# Lambda Configuration
variable "lambda_runtime" {
  description = "Runtime for Lambda function"
  type        = string
  default     = "nodejs18.x"

  validation {
    condition     = contains(["nodejs16.x", "nodejs18.x", "python3.8", "python3.9", "python3.10", "python3.11"], var.lambda_runtime)
    error_message = "Runtime must be one of the supported Lambda runtimes"
  }
}

variable "lambda_memory_size" {
  description = "Memory size for Lambda function in MB"
  type        = number
  default     = 128

  validation {
    condition     = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240
    error_message = "Memory size must be between 128 MB and 10,240 MB"
  }
}

variable "lambda_timeout" {
  description = "Timeout for Lambda function in seconds"
  type        = number
  default     = 30

  validation {
    condition     = var.lambda_timeout >= 1 && var.lambda_timeout <= 900
    error_message = "Timeout must be between 1 and 900 seconds"
  }
}

variable "lambda_environment_variables" {
  description = "Environment variables for Lambda function"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "lambda_vpc_config" {
  description = "VPC configuration for Lambda function"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

# Lambda Traffic Shifting Configuration
variable "lambda_traffic_shifting_enabled" {
  description = "Enable traffic shifting between Lambda versions"
  type        = bool
  default     = false
}

variable "lambda_previous_version" {
  description = "Previous Lambda version for traffic shifting"
  type        = string
  default     = null
}

variable "lambda_traffic_shift_percentage" {
  description = "Percentage of traffic to shift to previous version"
  type        = number
  default     = null

  validation {
    condition     = var.lambda_traffic_shift_percentage == null || (var.lambda_traffic_shift_percentage >= 0 && var.lambda_traffic_shift_percentage <= 1)
    error_message = "Traffic shift percentage must be between 0 and 1"
  }
}

# Lambda Function URL Configuration
variable "enable_function_url" {
  description = "Enable Lambda Function URL"
  type        = bool
  default     = false
}

variable "function_url_auth_type" {
  description = "Authorization type for Lambda Function URL"
  type        = string
  default     = "NONE"

  validation {
    condition     = contains(["NONE", "AWS_IAM"], var.function_url_auth_type)
    error_message = "Authorization type must be either NONE or AWS_IAM"
  }
}

variable "cors_allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

# Monitoring and Logging Configuration
variable "enable_xray_tracing" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be one of the allowed values"
  }
}

# API Gateway Configuration
variable "api_gateway_metrics_enabled" {
  description = "Enable API Gateway metrics"
  type        = bool
  default     = true
}

variable "api_gateway_logging_level" {
  description = "Logging level for API Gateway"
  type        = string
  default     = "INFO"

  validation {
    condition     = contains(["OFF", "INFO", "ERROR"], var.api_gateway_logging_level)
    error_message = "Logging level must be one of: OFF, INFO, ERROR"
  }
}

# Tags
variable "additional_tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
