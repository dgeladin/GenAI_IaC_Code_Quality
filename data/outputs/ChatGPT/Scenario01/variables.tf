# Filename: variables.tf

variable "ami_id" {
  description = "Map of AMI IDs for different OS types"
  type        = map(string)
}

variable "instance_type" {
  description = "Map of instance types for each environment"
  type        = map(map(string))
}

variable "instance_count" {
  description = "Map of instance counts for each OS type in each environment"
  type        = map(map(number))
}
