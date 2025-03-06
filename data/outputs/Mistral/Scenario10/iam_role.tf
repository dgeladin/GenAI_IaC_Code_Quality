provider "aws" {
  alias  = "primary"
  region = var.region_primary
}

provider "aws" {
  alias  = "dr"
  region = var.region_dr
}
