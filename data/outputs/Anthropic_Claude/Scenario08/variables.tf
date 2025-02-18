# File: variables.tf
variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instances"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI (adjust as needed)
}

variable "instance_type" {
  description = "The instance type to use for the EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "The key pair name to use for SSH access (if needed)"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "The VPC ID where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs where instances can be launched"
  type        = list(string)
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with the instances"
  type        = list(string)
  default     = []
}

variable "iam_instance_profile_name" {
  description = "The IAM instance profile name to attach to instances"
  type        = string
  default     = null
}

variable "min_size" {
  description = "The minimum size of the Auto Scaling group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum size of the Auto Scaling group"
  type        = number
  default     = 5
}

variable "desired_capacity" {
  description = "The desired capacity of the Auto Scaling group"
  type        = number
  default     = 2
}

variable "on_demand_percentage" {
  description = "Percentage of On-Demand instances in the ASG (0-100)"
  type        = number
  default     = 50
  
  validation {
    condition     = var.on_demand_percentage >= 0 && var.on_demand_percentage <= 100
    error_message = "The on_demand_percentage must be between 0 and 100."
  }
}

variable "spot_instance_pools" {
  description = "Number of Spot pools to use (instance types)"
  type        = number
  default     = 2
}

variable "spot_allocation_strategy" {
  description = "Spot allocation strategy"
  type        = string
  default     = "capacity-optimized"
  
  validation {
    condition     = contains(["price-capacity-optimized", "capacity-optimized", "lowest-price"], var.spot_allocation_strategy)
    error_message = "The spot allocation strategy must be one of: price-capacity-optimized, capacity-optimized, or lowest-price."
  }
}

variable "instance_weights" {
  description = "Map of instance types to their relative weights (capacity units)"
  type        = map(number)
  default     = {
    "t3.micro"  = 1
    "t3a.micro" = 1
    "t3.small"  = 2
    "t3a.small" = 2
  }
}

variable "capacity_unit" {
  description = "Whether the ASG desired/min/max are specified in instances or weighted capacity units"
  type        = string
  default     = "units"
  
  validation {
    condition     = contains(["units", "instances"], var.capacity_unit)
    error_message = "capacity_unit must be either 'units' or 'instances'."
  }
}

variable "on_demand_base_capacity" {
  description = "Minimum amount of capacity units to provision as On-Demand"
  type        = number
  default     = 1
}

variable "scale_up_threshold" {
  description = "Memory utilization threshold for scaling up (percentage)"
  type        = number
  default     = 75
}

variable "scale_down_threshold" {
  description = "Memory utilization threshold for scaling down (percentage)"
  type        = number
  default     = 30
}

variable "scale_up_adjustment" {
  description = "Number of capacity units to add when scaling up"
  type        = number
  default     = 1
}

variable "scale_down_adjustment" {
  description = "Number of capacity units to remove when scaling down"
  type        = number
  default     = -1
}

variable "scaling_cooldown" {
  description = "Cooldown period (in seconds) between scaling activities"
  type        = number
  default     = 300
}

variable "tags" {
  description = "Map of tags to apply to all resources"
  type        = map(string)
  default     = {
    Project     = "example-asg"
    Environment = "dev"
    Terraform   = "true"
    Owner       = "platform-team"
  }
}

variable "asg_tags" {
  description = "Additional tags specific to ASG instances"
  type        = map(string)
  default     = {
    Type        = "ASG-Instance"
    ManagedBy   = "terraform"
    BackupDaily = "true"
  }
}