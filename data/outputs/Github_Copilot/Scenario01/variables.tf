variable "environment" {
  description = "The environment name, defaulting to the current Terraform workspace"
  type        = string
}

variable "instance_type" {
  description = "Map of instance types for different environments"
  type        = map(string)
  default = {
    default = "t2.micro"
    dev     = "t2.small"
    prod    = "t2.medium"
  }
}

variable "ami_id" {
  description = "AMI IDs for different operating systems"
  type = object({
    windows = string
    linux   = string
  })
  default = {
    windows = "ami-0abcdef1234567890" # Replace with actual Windows AMI ID
    linux   = "ami-0abcdef1234567890" # Replace with actual AWS Linux AMI ID
  }
}