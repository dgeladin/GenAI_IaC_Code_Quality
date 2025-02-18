provider "aws" {
  region = var.primary_region
  
  default_tags {
    tags = var.default_tags
  }
}

provider "aws" {
  alias  = "west"
  region = var.secondary_region

  default_tags {
    tags = var.default_tags
  }
}
