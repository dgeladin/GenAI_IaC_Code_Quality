provider "aws" {
  alias  = "primary"
  region = var.region_primary
}

data "aws_availability_zones" "available" {
  provider = aws.primary
  state    = "available"
}

resource "aws_instance" "primary" {
  provider      = aws.primary
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "primary-instance"
    Environment = "primary"
  }
}

resource "aws_ebs_volume" "primary_data" {
  provider      = aws.primary
  availability_zone = data.aws_availability_zones.available.names[0]
  size          = 100
  type          = "gp3"

  tags = {
    Name        = "primary-data-volume"
    Environment = "primary"
  }
}

resource "aws_volume_attachment" "primary_data_attachment" {
  provider      = aws.primary
  device_name   = "/dev/sdf"
  volume_id     = aws_ebs_volume.primary_data.id
  instance_id   = aws_instance.primary.id
}
