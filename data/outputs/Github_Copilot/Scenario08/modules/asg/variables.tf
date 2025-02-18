variable "launch_template_id" {
  description = "The ID of the launch template to use for the Auto Scaling group"
  type        = string
}

variable "subnet_ids" {
  description = "List of VPC subnet IDs for the Auto Scaling group"
  type        = list(string)
}

variable "desired_capacity" {
  description = "The desired number of instances in the Auto Scaling group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "The minimum number of instances in the Auto Scaling group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of instances in the Auto Scaling group"
  type        = number
  default     = 4
}

variable "on_demand_base_capacity" {
  description = "The base capacity of On-Demand instances in the Auto Scaling group"
  type        = number
  default     = 1
}

variable "on_demand_percentage_above_base_capacity" {
  description = "The percentage of On-Demand instances above the base capacity in the Auto Scaling group"
  type        = number
  default     = 50
}

variable "environment" {
  description = "The environment for tagging purposes"
  type        = string
  default     = "development"
}

variable "instance_type_overrides" {
  description = "List of instance types and their weighted capacities for the Auto Scaling group"
  type = list(object({
    instance_type    = string
    weighted_capacity = string
  }))
}

variable "tags" {
  description = "Tags to apply to the Auto Scaling group instances"
  type = map(string)
}