variable "environment" {
  type        = string
  description = "Environment name (e.g., prod, staging)"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Environment name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the primary instance"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the primary instance"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the instance will be launched"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the instance will be launched"
}

variable "volume_type" {
  type        = string
  description = "EBS volume type"
  default     = "gp3"
}

variable "volume_size" {
  type        = number
  description = "Size of the EBS volume in GB"
  default     = 100
}

variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  description = "List of ingress rules for the security group"
  default     = []
}

variable "cpu_threshold" {
  type        = number
  description = "CPU utilization threshold for alarm"
  default     = 80
}

variable "alarm_actions" {
  type        = list(string)
  description = "List of ARNs to notify when alarm triggers"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
