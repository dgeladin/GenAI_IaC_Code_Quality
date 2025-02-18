
variable "environment" {
  description = "The environment to deploy into"
  type        = string
  default     = "development"
}

variable "aws_region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}
