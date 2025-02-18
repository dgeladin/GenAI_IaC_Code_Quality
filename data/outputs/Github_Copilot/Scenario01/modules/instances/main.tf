variable "environment" {
  description = "The environment name, defaulting to the current Terraform workspace"
  type        = string
}

variable "instance_type" {
  description = "Map of instance types for different environments"
  type        = map(string)
}

variable "ami_id" {
  description = "AMI IDs for different operating systems"
  type = object({
    windows = string
    linux   = string
  })
}

# Windows instances in dev environment
resource "aws_instance" "windows_dev" {
  count = var.environment == "dev" ? 1 : 0
  ami           = var.ami_id.windows
  instance_type = var.instance_type[var.environment]
  tags = {
    Name       = "example-instance-${var.environment}"
    created_by = "Terraform"
  }
}

# Windows instances in prod environment
resource "aws_instance" "windows_prod" {
  count = var.environment == "prod" ? 2 : 0
  ami           = var.ami_id.windows
  instance_type = var.instance_type[var.environment]
  tags = {
    Name       = "example-instance-${var.environment}-${count.index + 1}"
    created_by = "Terraform"
  }
}

# AWS Linux instances in dev environment
resource "aws_instance" "linux_dev" {
  count = var.environment == "dev" ? 1 : 0
  ami           = var.ami_id.linux
  instance_type = var.instance_type[var.environment]
  tags = {
    Name       = "example-instance-${var.environment}"
    created_by = "Terraform"
  }
}

# AWS Linux instances in prod environment
resource "aws_instance" "linux_prod" {
  count = var.environment == "prod" ? 3 : 0
  ami           = var.ami_id.linux
  instance_type = var.instance_type[var.environment]
  tags = {
    Name       = "example-instance-${var.environment}-${count.index + 1}"
    created_by = "Terraform"
  }
}