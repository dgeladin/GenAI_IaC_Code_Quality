# variables.tf

# Provider Configuration Variables
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "datadog_api_key" {
  description = "Datadog API key for authentication"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog Application key for authentication"
  type        = string
  sensitive   = true
}

# AWS Resource Variables
variable "aws_ami_id" {
  description = "AMI ID for the AWS EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "aws_instance_type" {
  description = "Instance type for the AWS EC2 instance"
  type        = string
  default     = "t3.micro"
}

# Azure Resource Variables
variable "azure_location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "azure_resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "example-resources"
}

variable "azure_vm_name" {
  description = "Name of the Azure virtual machine"
  type        = string
  default     = "example-vm"
}

variable "azure_vm_size" {
  description = "Size of the Azure virtual machine"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "azure_admin_username" {
  description = "Username for the Azure VM admin account"
  type        = string
  default     = "azureuser"
}

variable "azure_ssh_public_key" {
  description = "SSH public key for Azure VM authentication"
  type        = string
  sensitive   = true
}

# Monitoring Variables
variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "production"
}

variable "cpu_critical_threshold" {
  description = "Critical threshold for CPU utilization (%)"
  type        = number
  default     = 80
}

variable "cpu_warning_threshold" {
  description = "Warning threshold for CPU utilization (%)"
  type        = number
  default     = 70
}

variable "cpu_critical_recovery" {
  description = "Recovery threshold for critical CPU alerts (%)"
  type        = number
  default     = 75
}

variable "cpu_warning_recovery" {
  description = "Recovery threshold for warning CPU alerts (%)"
  type        = number
  default     = 65
}

# Default Tags
variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Terraform   = "true"
    Project     = "multicloud-monitoring"
  }
}