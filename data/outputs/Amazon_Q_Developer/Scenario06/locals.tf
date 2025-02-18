# locals.tf

locals {
  # Common tags for all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Terraform   = "true"
    Owner       = var.owner
  }

  # API Gateway resource path
  api_path = "example"

  # Lambda function configuration
  lambda_timeout     = 30
  lambda_memory_size = 128
}
