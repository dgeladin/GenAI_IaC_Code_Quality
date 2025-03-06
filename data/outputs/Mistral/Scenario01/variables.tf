# Define the environment variable with a default value of the current Terraform workspace
variable "environment" {
  description = "The environment name, defaults to the current Terraform workspace"
  type        = string
}

# Define the instance_type variable as a map of strings with default values for different environments
variable "instance_type" {
  description = "Map of instance types for different environments"
  type        = map(string)
  default = {
    default = "t2.micro"
    dev     = "t2.small"
    prod    = "t2.medium"
  }
}

# Define the ami_id variable for Windows AMI
variable "ami_id_windows" {
  description = "The AMI ID for Windows instances"
  type        = string
  default     = "ami-0abcdef1234567890" # Replace with the actual Windows AMI ID
}

# Define the ami_id variable for AWS Linux AMI
variable "ami_id_linux" {
  description = "The AMI ID for AWS Linux instances"
  type        = string
  default     = "ami-0abcdef1234567890" # Replace with the actual AWS Linux AMI ID
}
