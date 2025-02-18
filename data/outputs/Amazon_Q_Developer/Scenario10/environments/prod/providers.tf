provider "aws" {
  region = var.primary_region
  
  default_tags {
    tags = {
      Project     = "DR-Infrastructure"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

provider "aws" {
  alias  = "dr_region"
  region = var.dr_region
  
  default_tags {
    tags = {
      Project     = "DR-Infrastructure"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

provider "aws" {
  alias  = "primary_region"
  region = var.primary_region
  
  default_tags {
    tags = {
      Project     = "DR-Infrastructure"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
