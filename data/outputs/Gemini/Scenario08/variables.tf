# variables.tf

variable "region" {
  type    = string
  default = "us-east-1" # Replace with your desired region
  description = "AWS region"
}

variable "ami_name_filter" {
  type    = string
  default = "amzn-ami-*"
  description = "Filter for AMI name"
}

variable "instance_type_on_demand" {
  type    = string
  default = "t3.micro"
  description = "On-demand instance type"
}

variable "instance_type_spot1" {
  type    = string
  default = "t3.micro"
  description = "Spot instance type 1"
}

variable "instance_type_spot2" {
  type    = string
  default = "t3.small"
  description = "Spot instance type 2"
}

variable "subnet_ids" {
  type    = list(string)
  description = "List of subnet IDs"
}

variable "security_group_ids" {
  type    = list(string)
  description = "List of security group IDs"
}

variable "iam_instance_profile_arn" {
  type    = string
  description = "ARN of the IAM instance profile"
}

variable "desired_capacity" {
  type    = number
  default = 2
  description = "Desired capacity of the ASG"
}

variable "min_size" {
  type    = number
  default = 1
  description = "Minimum size of the ASG"
}

variable "max_size" {
  type    = number
  default = 5
  description = "Maximum size of the ASG"
}

variable "on_demand_base_capacity" {
  type = number
  default = 1
  description = "Number of on-demand instances to provision"
}

variable "on_demand_percentage_above_base_capacity" {
  type = number
  default = 50
  description = "Percentage of on-demand instances above base capacity"
}

variable "spot_weight_1" {
  type = string
  default = "1"
  description = "Weight for spot instance type 1"
}

variable "spot_weight_2" {
  type = string
  default = "2"
  description = "Weight for spot instance type 2"
}

variable "target_cpu_utilization_up" {
  type = number
  default = 70.0
  description = "Target CPU utilization for scaling up"
}

variable "target_cpu_utilization_down" {
  type = number
  default = 30.0
  description = "Target CPU utilization for scaling down"
}

# Add more variables as needed