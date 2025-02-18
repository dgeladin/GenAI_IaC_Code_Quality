# Production environment backend configuration

bucket         = "terraform-state-multi-env-infra-prod"
key            = "terraform/prod/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-locks-multi-env-infra-prod"
encrypt        = true