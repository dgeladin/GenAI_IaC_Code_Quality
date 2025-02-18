variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "development"
}

variable "location" {
  description = "Azure region for deploying resources"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vnet_cidr" {
  description = "CIDR block for virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for VM authentication"
  type        = string
}

variable "os_disk_size" {
  description = "Size of the OS disk in GB"
  type        = number
  default     = 30

  validation {
    condition     = var.os_disk_size >= 30 && var.os_disk_size <= 100
    error_message = "OS disk size must be between 30 and 100 GB."
  }
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH to the VM"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Note: Should be restricted in production
}

variable "alert_email" {
  description = "Email address for monitoring alerts"
  type        = string
}

variable "disk_encryption_set_id" {
  description = "ID of the disk encryption set for OS disk encryption"
  type        = string
  default     = null
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "development"
    Project     = "monitoring"
  }
}
