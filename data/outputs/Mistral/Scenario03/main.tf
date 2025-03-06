# main.tf

terraform {
  required_version = ">= 1.8"

  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "eks-cluster/terraform.tfstate"
    region = "us-east-1"
  }
}
