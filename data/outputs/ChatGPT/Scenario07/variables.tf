variable "environment" {
  description = "The environment name (derived from Terraform workspace)"
  type        = string
  default     = "development"
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

