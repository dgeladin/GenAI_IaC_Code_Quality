locals {
  # Environment settings
  active_environment = coalesce(var.environment, terraform.workspace)
  
  # Instance type selection
  active_instance_type = lookup(var.instance_type, terraform.workspace, var.instance_type["default"])

  # Instance counts per environment
  windows_instance_count = {
    default = 0
    dev     = 1
    prod    = 2
  }

  linux_instance_count = {
    default = 0
    dev     = 1
    prod    = 3
  }

  # Active counts based on workspace
  active_windows_count = lookup(local.windows_instance_count, terraform.workspace, 0)
  active_linux_count   = lookup(local.linux_instance_count, terraform.workspace, 0)

  # Common tags
  common_tags = {
    Environment = terraform.workspace
    ManagedBy   = "terraform"
    Workspace   = terraform.workspace
    created_by  = "terraform"
  }
}
