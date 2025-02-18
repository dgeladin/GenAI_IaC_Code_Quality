terraform {
  backend "s3" {
    # These values should be provided during terraform init or via backend configuration
    # bucket         = "XXXXXXXXXXXXXXXXXXXXXX"
    # key            = "rds/terraform.tfstate"
    # region         = "us-east-1"
    # dynamodb_table = "terraform-state-lock"
    # encrypt        = true
    # kms_key_id     = "arn:aws:kms:us-east-1:ACCOUNT-ID:key/KEY-ID"
  }
}
