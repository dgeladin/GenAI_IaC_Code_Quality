variable "environment" {
  description = "Environment name from workspace"
  type        = string
}

variable "project" {
  description = "Project name for resource tagging"
  type        = string
}

variable "db_instance_arn" {
  description = "ARN of the RDS instance"
  type        = string
}

variable "db_resource_id" {
  description = "Resource ID of the RDS instance"
  type        = string
}
