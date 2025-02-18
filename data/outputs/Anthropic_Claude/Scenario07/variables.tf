# Root module - variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "multi-env-infra"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "dbadmin"
}

variable "db_password_dev" {
  description = "Password for the dev database"
  type        = string
  sensitive   = true
}

variable "db_password_staging" {
  description = "Password for the staging database"
  type        = string
  sensitive   = true
}

variable "db_password_prod" {
  description = "Password for the prod database"
  type        = string
  sensitive   = true
}