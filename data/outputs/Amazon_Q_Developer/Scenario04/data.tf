# Get the AWS account ID for the ELB service account
data "aws_elb_service_account" "current" {}

# Get the current AWS region
data "aws_region" "current" {}
