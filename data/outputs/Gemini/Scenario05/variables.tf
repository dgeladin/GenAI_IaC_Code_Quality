variable "db_username" {
  type = string
  description = "Username for the RDS database"
  sensitive = true
}

variable "db_password" {
  type = string
  description = "Password for the RDS database"
  sensitive = true
}

variable "private_subnet_ids" {
  type = list(string)
  description = "List of private subnet IDs"
}

variable "vpc_cidr" {
  type = string
  description = "CIDR block for the VPC"
  default = "10.0.0.0/16"
}