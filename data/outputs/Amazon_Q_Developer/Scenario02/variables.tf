variable "primary_region" {
  type        = string
  description = "Primary AWS region for deployment"
  default     = "us-east-1"
}

variable "secondary_region" {
  type        = string
  description = "Secondary AWS region for deployment"
  default     = "us-west-2"
}

variable "vpc_cidr_east" {
  type        = string
  description = "CIDR block for East region VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_cidr_west" {
  type        = string
  description = "CIDR block for West region VPC"
  default     = "10.1.0.0/16"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags for all resources"
  default = {
    Environment = "production"
    Terraform   = "true"
    Project     = "multi-region-ha"
  }
}

variable "enable_flow_logs" {
  type        = bool
  description = "Enable flow logs for Global Accelerator"
  default     = true
}

variable "flow_logs_retention_days" {
  type        = number
  description = "Number of days to retain flow logs"
  default     = 7
}
