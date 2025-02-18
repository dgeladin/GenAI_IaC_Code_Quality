variable "vpc_id" {
  type        = string
  description = "VPC ID where the ASG will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the ASG"
}

variable "app_name" {
  type        = string
  description = "Name of the application"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "region_name" {
  type        = string
  description = "Region identifier (east/west)"
}

variable "min_size" {
  type        = number
  description = "Minimum size of the Auto Scaling Group"
  default     = 2
}

variable "max_size" {
  type        = number
  description = "Maximum size of the Auto Scaling Group"
  default     = 5
}

variable "desired_capacity" {
  type        = number
  description = "Desired capacity of the Auto Scaling Group"
  default     = 2
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}
