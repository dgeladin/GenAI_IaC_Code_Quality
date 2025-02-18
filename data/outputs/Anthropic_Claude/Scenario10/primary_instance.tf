# filename: primary_instance.tf

# Get the availability zone
data "aws_availability_zones" "PrimaryAZs" {
  state = "available"
  
  filter {
    name   = "region-name"
    values = ["us-west-2"]
  }
}

# EC2 instance in primary region
resource "aws_instance" "primary" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  
  availability_zone = data.aws_availability_zones.PrimaryAZs.names[0]
  subnet_id        = var.subnet_id
  
  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
    kms_key_id  = aws_kms_key.dr_key.arn
  }

  metadata_options {
    http_tokens = "required" # IMDSv2
  }

  tags = merge(
    var.common_tags,
    {
      Name = "Primary-Instance"
    }
  )
}

# EBS volume for data
resource "aws_ebs_volume" "primary_data" {
  availability_zone = aws_instance.primary.availability_zone
  size             = var.data_volume_size
  type             = "gp3"
  encrypted        = true
  kms_key_id       = aws_kms_key.dr_key.arn

  tags = merge(
    var.common_tags,
    {
      Name = "Primary-Data-Volume"
    }
  )
}

# Volume attachment
resource "aws_volume_attachment" "primary_data_attachment" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.primary_data.id
  instance_id = aws_instance.primary.id
  skip_destroy = true
}