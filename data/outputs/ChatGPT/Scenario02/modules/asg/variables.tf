variable "vpc_id" {
  description = "The VPC ID where the ASG will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of public subnet IDs for the ASG"
  type        = list(string)
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
}

variable "application_name" {
  description = "Name of the application"
  type        = string
}

