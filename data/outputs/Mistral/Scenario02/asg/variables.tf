# asg/variables.tf

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs."
  type        = list(string)
}

variable "min_size" {
  description = "The minimum size of the Auto Scaling Group."
  type        = number
}

variable "max_size" {
  description = "The maximum size of the Auto Scaling Group."
  type        = number
}

variable "desired_capacity" {
  description = "The desired capacity of the Auto Scaling Group."
  type        = number
}

variable "instance_type" {
  description = "The type of instance to launch."
  type        = string
}

variable "application_name" {
  description = "The name of the application."
  type        = string
}
