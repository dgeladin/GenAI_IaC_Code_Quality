terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  alias   = "primary"
  region  = "us-west-2"
}

resource "aws_instance" "primary" {
  provider = aws.primary

  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  tags = {
    Name        = "primary-instance"
    Environment = "Primary"
  }
}

resource "aws_ebs_volume" "primary_data" {
  provider        = aws.primary
  availability_zone = aws_instance.primary.availability_zone
  size            = 100
  type            = "gp3"

  tags = {
    Name        = "primary-data-volume"
    Environment = "Primary"
  }
}

resource "aws_volume_attachment" "primary_data_attachment" {
  provider = aws.primary

  device_name = "/dev/xvdf"
  instance_id = aws_instance.primary.id
  volume_id   = aws_ebs_volume.primary_data.id

  force_detach = true
}

output "primary_instance_id" {
  value = aws_instance.primary.id
}

output "primary_data_volume_id" {
  value = aws_ebs_volume.primary_data.id
}