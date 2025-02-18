# Development environment backend configuration

bucket         = "terraform-state-multi-env-infra-dev"
key            = "terraform/dev/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-locks-multi-env-infra-dev"
encrypt        = true