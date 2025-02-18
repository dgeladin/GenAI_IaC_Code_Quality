# Staging environment backend configuration

bucket         = "terraform-state-multi-env-infra-staging"
key            = "terraform/staging/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-locks-multi-env-infra-staging"
encrypt        = true