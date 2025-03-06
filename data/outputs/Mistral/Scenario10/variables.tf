variable "region_primary" {
  description = "The primary AWS region"
  type        = string
  default     = "us-west-2"
}

variable "region_dr" {
  description = "The DR AWS region"
  type        = string
  default     = "us-east-1"
}

variable "dr_configuration_id" {
  description = "The DRS replication configuration template ID"
  type        = string
}
