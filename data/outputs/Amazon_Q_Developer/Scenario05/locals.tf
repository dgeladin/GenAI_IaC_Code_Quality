locals {
  # Account and region information
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  
  # Resource naming
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Database configuration
  db_identifier = "${local.name_prefix}-mysql"
  db_port       = 3306
  
  # Timestamp for unique naming
  timestamp = data.time_static.current.rfc3339

  # Common tags to be applied to all resources
  common_tags = {
    Environment     = var.environment
    Project         = var.project_name
    Terraform       = "true"
    ManagedBy      = "terraform"
    Owner          = var.owner
    CreatedBy      = data.aws_caller_identity.current.arn
    CreatedAt      = local.timestamp
  }

  # Backup configuration
  backup_window      = "03:00-04:00"
  maintenance_window = "Mon:04:00-Mon:05:00"

  # Security group configuration
  sg_name = "${local.name_prefix}-db-sg"
  
  # Subnet group configuration
  subnet_group_name = "${local.name_prefix}-subnet-group"

  # Migration configuration
  migration_version = "V1"
  
  # Enhanced monitoring configuration
  monitoring_role_name = "${local.name_prefix}-monitoring-role"

  # Parameter group configuration
  parameter_group_name = "${local.name_prefix}-parameter-group"
  
  # Option group configuration
  option_group_name = "${local.name_prefix}-option-group"

  # Determine if this is a production environment
  is_production = var.environment == "prod"

  # Database configuration based on environment
  db_config = {
    prod = {
      instance_class        = "db.t3.medium"
      allocated_storage    = 50
      multi_az            = true
      deletion_protection = true
      backup_retention    = 30
      skip_final_snapshot = false
    }
    dev = {
      instance_class        = "db.t3.micro"
      allocated_storage    = 20
      multi_az            = false
      deletion_protection = false
      backup_retention    = 7
      skip_final_snapshot = true
    }
  }

  # Use environment specific configuration
  db_settings = local.db_config[local.is_production ? "prod" : "dev"]

  # Security group rules
  sg_rules = {
    ingress = {
      description = "MySQL from VPC"
      from_port   = local.db_port
      to_port     = local.db_port
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.selected.cidr_block]
    }
    egress = {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # SSM Parameter paths
  ssm_path_prefix = "/${var.environment}/database"
  ssm_parameters = {
    migration_status = "${local.ssm_path_prefix}/migration-status"
    endpoint        = "${local.ssm_path_prefix}/endpoint"
    port           = "${local.ssm_path_prefix}/port"
  }

  # Monitoring and logging
  log_types = [
    "general",
    "error",
    "slowquery",
    "audit"
  ]

  # Backup configuration
  backup_config = {
    retention_period = local.db_settings.backup_retention
    window          = local.backup_window
    snapshot_identifier = local.is_production ? "${local.name_prefix}-final-snapshot" : null
  }
}
