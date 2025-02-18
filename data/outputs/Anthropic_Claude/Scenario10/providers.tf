# filename: providers.tf

provider "aws" {
  region = local.primary_region  # us-west-2

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias  = "dr_region"
  region = local.dr_region  # us-east-1

  default_tags {
    tags = local.default_tags
  }
}

# Enable data source to get account ID
data "aws_caller_identity" "current" {}