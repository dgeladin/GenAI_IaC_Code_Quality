# Specify the required Terraform version
terraform {
  required_version = ">= 1.8"

  # Define the backend configuration if needed
  # backend "s3" {
  #   bucket = "my-terraform-state"
  #   key    = "path/to/my/key"
  #   region = "us-east-1"
  # }
}
