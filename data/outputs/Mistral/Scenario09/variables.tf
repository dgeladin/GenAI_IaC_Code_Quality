variable "aws_ami" {
  description = "The AMI ID to use for the EC2 instance."
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "aws_instance_type" {
  description = "The type of EC2 instance to launch."
  type        = string
  default     = "t3.micro"
}

variable "azure_location" {
  description = "The Azure region to deploy resources in."
  type        = string
  default     = "East US"
}

variable "azure_vm_size" {
  description = "The size of the Azure VM to launch."
  type        = string
  default     = "Standard_DS1_v2"
}

variable "azure_admin_username" {
  description = "The admin username for the Azure VM."
  type        = string
  default     = "azureuser"
}

variable "azure_admin_password" {
  description = "The admin password for the Azure VM."
  type        = string
  sensitive   = true
}

variable "datadog_api_key" {
  description = "The Datadog API key."
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "The Datadog application key."
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "The environment name (e.g., production, staging)."
  type        = string
  default     = "production"
}
