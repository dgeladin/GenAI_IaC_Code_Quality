# Get current AWS region
data "aws_region" "current" {}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Get VPC details
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# Get KMS key for encryption (if using custom key)
data "aws_kms_key" "rds" {
  count = var.use_custom_kms_key ? 1 : 0
  key_id = var.kms_key_id
}

# Get current timestamp for resource naming
data "time_static" "current" {}
