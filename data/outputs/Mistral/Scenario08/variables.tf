variable "vpc_subnets" {
  description = "A list of VPC subnet IDs to launch instances in."
  type        = list(string)
}

variable "desired_capacity" {
  description = "The desired capacity of the Auto Scaling group."
  type        = number
}

variable "min_size" {
  description = "The minimum size of the Auto Scaling group."
  type        = number
}

variable "max_size" {
  description = "The maximum size of the Auto Scaling group."
  type        = number
}

variable "on_demand_base_capacity" {
  description = "The number of On-Demand instances to launch as a base number before fulfilling On-Demand capacity."
  type        = number
  default     = 1
}

variable "on_demand_percentage_above_base_capacity" {
  description = "The percentage of On-Demand instances to launch above the base capacity."
  type        = number
  default     = 20
}
