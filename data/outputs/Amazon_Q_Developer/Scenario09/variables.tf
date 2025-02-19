# General Variables
variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "development"
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    Terraform = "true"
    Project   = "multicloud-monitoring"
  }
}

variable "cost_center" {
  description = "Cost center for resource tagging"
  type        = string
  default     = "engineering"
}

# AWS Variables
variable "aws_region" {
  description = "AWS region for deploying resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "aws_ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "aws_instance_type" {
  description = "Instance type for EC2"
  type        = string
  default     = "t3.micro"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for AWS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_subnet_cidr" {
  description = "CIDR block for AWS subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "aws_root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "aws_integration_role_name" {
  description = "IAM role name for Datadog integration"
  type        = string
  default     = "DatadogIntegrationRole"
}

variable "aws_alarm_actions" {
  description = "List of ARNs for AWS alarm actions"
  type        = list(string)
  default     = []
}

# Azure Variables
variable "azure_location" {
  description = "Azure region for deploying resources"
  type        = string
  default     = "eastus"
}

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "azure_tenant_name" {
  description = "Azure tenant name"
  type        = string
}

variable "azure_client_id" {
  description = "Azure client ID"
  type        = string
}

variable "azure_client_secret" {
  description = "Azure client secret"
  type        = string
  sensitive   = true
}

variable "azure_resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "azure_vnet_cidr" {
  description = "CIDR block for Azure VNet"
  type        = string
  default     = "10.1.0.0/16"
}

variable "azure_subnet_cidr" {
  description = "CIDR block for Azure subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "azure_vm_name" {
  description = "Name of the Azure VM"
  type        = string
}

variable "azure_vm_size" {
  description = "Size of the Azure VM"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "azure_admin_username" {
  description = "Admin username for Azure VM"
  type        = string
  default     = "azureuser"
}

variable "azure_ssh_public_key" {
  description = "SSH public key for Azure VM"
  type        = string
}

variable "azure_os_disk_size" {
  description = "Size of the Azure VM OS disk in GB"
  type        = number
  default     = 30
}

# Datadog Variables
variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog application key"
  type        = string
  sensitive   = true
}

# Monitoring Variables
variable "cpu_threshold_critical" {
  description = "Critical threshold for CPU usage"
  type        = number
  default     = 80
}

variable "cpu_threshold_warning" {
  description = "Warning threshold for CPU usage"
  type        = number
  default     = 70
}

variable "memory_threshold_critical" {
  description = "Critical threshold for memory usage"
  type        = number
  default     = 85
}

variable "memory_threshold_warning" {
  description = "Warning threshold for memory usage"
  type        = number
  default     = 75
}

variable "disk_threshold_critical" {
  description = "Critical threshold for disk usage"
  type        = number
  default     = 90
}

variable "disk_threshold_warning" {
  description = "Warning threshold for disk usage"
  type        = number
  default     = 80
}

# Security Variables
variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "notification_targets" {
  description = "Notification targets for alerts"
  type        = string
}

variable "alert_email" {
  description = "Email address for monitoring alerts"
  type        = string
}
