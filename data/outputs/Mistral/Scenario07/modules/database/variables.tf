variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)."
  type        = string
}

variable "db_name" {
  description = "The name of the database."
  type        = string
}

variable "db_username" {
  description = "The database username."
  type        = string
}

variable "db_password" {
  description = "The database password."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "The RDS instance class."
  type        = string
  default     = {
    development = "db.t3.micro"
    staging     = "db.t3.medium"
    production  = "db.m5.large"
  }
}

variable "db_allocated_storage" {
  description = "The allocated storage in GB."
  type        = number
  default     = 20
}

variable "db_port" {
  description = "The database port."
  type        = number
  default     = 5432
}

variable "db_subnet_group_name" {
  description = "The name of the DB subnet group."
  type        = string
}

variable "db_security_group_id" {
  description = "The ID of the database security group."
  type        = string
}
