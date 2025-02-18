variable "environment" {
  description = "Environment name from workspace"
  type        = string
}

variable "project" {
  description = "Project name for resource tagging"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of public subnets for the ALB"
  type        = list(string)
}

variable "web_server_sg_id" {
  description = "ID of the web server security group"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type based on environment"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3.medium", "t3.large"], var.instance_type)
    error_message = "Instance type must be t3.micro, t3.medium, or t3.large."
  }
}

variable "asg_desired_capacity" {
  description = "Desired capacity for ASG"
  type        = number
  default     = 2
}

variable "asg_min_size" {
  description = "Minimum size for ASG"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum size for ASG"
  type        = number
  default     = 5
}

variable "ssl_certificate_arn" {
  description = "ARN of SSL certificate for HTTPS listener"
  type        = string
}
