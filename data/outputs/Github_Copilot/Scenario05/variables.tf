variable "db_name" {
  description = "The name of the database to create."
  type        = string
  default     = "myapp"
}

variable "db_username" {
  description = "The username for the database."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the database."
  type        = string
  sensitive   = true
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID where the security group will be created."
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "List of allowed CIDR blocks for inbound traffic to the DB."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}