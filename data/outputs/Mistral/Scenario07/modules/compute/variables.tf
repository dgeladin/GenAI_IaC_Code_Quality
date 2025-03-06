variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)."
  type        = string
}

variable "instance_type" {
  description = "The instance type to use for the environment."
  type        = string
  default     = {
    dev        = "t3.micro"
    staging    = "t3.medium"
    production = "t3.large"
  }
}

variable "desired_capacity" {
  description = "The desired capacity for the ASG."
  type        = number
  default     = 2
}

variable "min_size" {
  description = "The minimum size for the ASG."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "The maximum size for the ASG."
  type        = number
  default     = 5
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets."
  type        = list(string)
}

variable "web_server_sg_id" {
  description = "The ID of the web server security group."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "certificate_arn" {
  description = "The ARN of the SSL certificate."
  type        = string
}
