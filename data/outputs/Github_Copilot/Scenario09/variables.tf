variable "datadog_api_key" {
  description = "API key for Datadog"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Application key for Datadog"
  type        = string
  sensitive   = true
}

variable "aws_instance_type" {
  description = "AWS EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "aws_ami" {
  description = "AWS AMI ID"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "azure_vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "azure_resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "example-resources"
}

variable "azure_vm_name" {
  description = "Azure VM name"
  type        = string
  default     = "example-vm"
}