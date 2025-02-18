variable "environment" {
  description = "Environment name - defaults to Terraform workspace"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "Map of environment to instance type"
  type        = map(string)
  default = {
    default = "t2.micro"
    dev     = "t2.small"
    prod    = "t2.medium"
  }
}

variable "ami_id" {
  description = "Map of OS type to AMI ID"
  type        = map(string)
  default = {
    windows = "ami-0c2b0d3fb02824d92"
    linux   = "ami-0cff7528ff583bf9a"
  }

  validation {
    condition     = can([for id in values(var.ami_id) : regex("^ami-[a-f0-9]{17}$", id)])
    error_message = "All AMI IDs must be valid ami-* format"
  }
}
