# variables.tf
variable "vpc_zone_identifier" {
  description = "List of subnet IDs where ASG instances will be launched"
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

variable "on_demand_base_capacity" {
  description = "Number of On-Demand instances guaranteed in ASG"
  type        = number
}

variable "on_demand_percentage_above_base_capacity" {
  description = "Percentage of additional On-Demand instances above base capacity"
  type        = number
}

variable "instance_profile" {
  description = "IAM instance profile for instances in the ASG"
  type        = string
}

variable "security_group_ids" {
  description = "List of security groups to assign to instances"
  type        = list(string)
}

