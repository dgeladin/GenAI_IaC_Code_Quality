# Main configuration for instance creation
resource "aws_instance" "windows_servers" {
  count = local.active_windows_count

  ami           = var.ami_id["windows"]
  instance_type = local.active_instance_type

  tags = merge(
    {
      Name        = "example-instance-${terraform.workspace}-windows-${count.index + 1}"
      created_by  = "terraform"
      OS          = "Windows"
      ServerIndex = count.index + 1
    },
    local.common_tags
  )

  root_block_device {
    volume_size = 50
    encrypted   = true
    tags = {
      Name = "example-instance-${terraform.workspace}-windows-${count.index + 1}-root"
    }
  }

  metadata_options {
    http_tokens = "required"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "linux_servers" {
  count = local.active_linux_count

  ami           = var.ami_id["linux"]
  instance_type = local.active_instance_type

  tags = merge(
    {
      Name        = "example-instance-${terraform.workspace}-linux-${count.index + 1}"
      created_by  = "terraform"
      OS          = "Linux"
      ServerIndex = count.index + 1
    },
    local.common_tags
  )

  root_block_device {
    volume_size = 30
    encrypted   = true
    tags = {
      Name = "example-instance-${terraform.workspace}-linux-${count.index + 1}-root"
    }
  }

  metadata_options {
    http_tokens = "required"
  }

  lifecycle {
    create_before_destroy = true
  }
}
