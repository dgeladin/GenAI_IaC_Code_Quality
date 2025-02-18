# filename: locals.tf

locals {
  # Region configurations
  primary_region = "us-west-2"
  dr_region      = "us-east-1"
  
  # Resource naming prefix
  resource_prefix = "${var.env_prefix}-dr"
  
  # Common tags with dynamic timestamp
  default_tags = merge(
    var.common_tags,
    {
      LastUpdated = formatdate("YYYY-MM-DD", timestamp())
      Project     = "Disaster-Recovery"
      ManagedBy   = "Terraform"
    }
  )

  # S3 bucket naming
  bucket_name = "${local.resource_prefix}-backup-${data.aws_caller_identity.current.account_id}"
  
  # Lambda function naming
  lambda_function_name = "${local.resource_prefix}-failover"
  
  # KMS key alias prefix
  kms_alias_prefix = "alias/${local.resource_prefix}"
}