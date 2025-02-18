terraform {
  backend "s3" {
    # These values should be provided during terraform init
    # bucket         = "XXXXXXXXXXXXXXXXXXXXXXXXXXX"
    # key            = "blue-green/terraform.tfstate"
    # region         = "us-east-1"
    # dynamodb_table = "terraform-state-lock"
    # encrypt        = true
  }
}
