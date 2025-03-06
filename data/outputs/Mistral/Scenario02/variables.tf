# variables.tf

variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "region" {
  description = "The AWS region for the VPC."
  type        = string
}
