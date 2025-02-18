locals {
  common_tags = {
    Environment = var.environment
    Project     = "example-db"
    ManagedBy   = "terraform"
    Owner       = "devops-team"
    CreatedBy   = "terraform"
  }

  db_tags = merge(
    local.common_tags,
    {
      Name = "example-db-${var.environment}"
      Service = "database"
      BackupSchedule = "daily"
    }
  )

  security_group_tags = merge(
    local.common_tags,
    {
      Name = "db-sg-${var.environment}"
      Service = "security"
    }
  )

  subnet_group_tags = merge(
    local.common_tags,
    {
      Name = "db-subnet-group-${var.environment}"
      Service = "networking"
    }
  )
}