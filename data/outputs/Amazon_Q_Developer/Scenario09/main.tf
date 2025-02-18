# AWS Resources
module "aws_resources" {
  source = "./modules/aws"

  environment         = var.environment
  aws_region         = var.aws_region
  ami_id             = var.aws_ami_id
  instance_type      = var.aws_instance_type
  vpc_cidr           = var.aws_vpc_cidr
  subnet_cidr        = var.aws_subnet_cidr
  root_volume_size   = var.aws_root_volume_size
  allowed_ssh_cidrs  = var.allowed_ssh_cidrs
  alarm_actions      = var.aws_alarm_actions
  
  default_tags = merge(
    var.default_tags,
    {
      Environment = var.environment
      Project     = "multicloud-monitoring"
    }
  )
}

# Azure Resources
module "azure_resources" {
  source = "./modules/azure"

  environment          = var.environment
  location            = var.azure_location
  resource_group_name = var.azure_resource_group_name
  vnet_cidr           = var.azure_vnet_cidr
  subnet_cidr         = var.azure_subnet_cidr
  vm_name             = var.azure_vm_name
  vm_size             = var.azure_vm_size
  admin_username      = var.azure_admin_username
  ssh_public_key      = var.azure_ssh_public_key
  os_disk_size        = var.azure_os_disk_size
  allowed_ssh_cidrs   = var.allowed_ssh_cidrs
  alert_email         = var.alert_email

  default_tags = merge(
    var.default_tags,
    {
      Environment = var.environment
      Project     = "multicloud-monitoring"
    }
  )
}

# Monitoring Configuration
module "monitoring" {
  source = "./modules/monitoring"

  environment = var.environment

  # AWS Configuration
  enable_aws_integration    = true
  aws_account_id           = var.aws_account_id
  aws_integration_role_name = var.aws_integration_role_name
  aws_instance_id          = module.aws_resources.instance_id
  aws_region               = var.aws_region

  # Azure Configuration
  enable_azure_integration = true
  azure_tenant_name       = var.azure_tenant_name
  azure_client_id         = var.azure_client_id
  azure_client_secret     = var.azure_client_secret
  azure_vm_name           = module.azure_resources.vm_name
  azure_resource_group    = module.azure_resources.resource_group_name
  azure_location          = var.azure_location

  # Monitoring Thresholds
  cpu_threshold_critical    = var.cpu_threshold_critical
  cpu_threshold_warning     = var.cpu_threshold_warning
  memory_threshold_critical = var.memory_threshold_critical
  memory_threshold_warning  = var.memory_threshold_warning
  disk_threshold_critical   = var.disk_threshold_critical
  disk_threshold_warning    = var.disk_threshold_warning

  # Notification Configuration
  notification_targets = var.notification_targets

  additional_tags = [
    "project:multicloud-monitoring",
    "team:devops",
    "cost-center:${var.cost_center}"
  ]
}
