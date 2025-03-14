# Filename: main.tf

provider "aws" {
  region = "us-east-1"
}

locals {
  environment      = terraform.workspace
  windows_ami      = var.ami_id["windows"]
  linux_ami        = var.ami_id["linux"]
  windows_type     = var.instance_type[local.environment]["windows"]
  linux_type       = var.instance_type[local.environment]["linux"]
  windows_count    = var.instance_count[local.environment]["windows"]
  linux_count      = var.instance_count[local.environment]["linux"]
}

resource "aws_instance" "windows" {
  count         = local.windows_count
  ami           = local.windows_ami
  instance_type = local.windows_type

  tags = {
    Name       = "example-instance-${local.environment}"
    created_by = "Terraform"
  }
}

resource "aws_instance" "linux" {
  count         = local.linux_count
  ami           = local.linux_ami
  instance_type = local.linux_type

  tags = {
    Name       = "example-instance-${local.environment}"
    created_by = "Terraform"
  }
}
