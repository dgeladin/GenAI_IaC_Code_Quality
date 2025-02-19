# primary_resources.tf

resource "aws_instance" "primary" {
  ami           = "ami-0c55b159cbfafe1f0" # Replace with your desired AMI
  instance_type = "t3.micro"
  availability_zone = "us-west-2a" # Choose an appropriate AZ

  tags = {
    Name        = "primary-instance"
    Environment = "primary"
  }
}

resource "aws_ebs_volume" "primary_data" {
  availability_zone = aws_instance.primary.availability_zone
  size              = 100
  type              = "gp3"

  tags = {
    Name        = "primary-data-volume"
    Environment = "primary"
  }
}

resource "aws_volume_attachment" "primary_data_attachment" {
  device_name = "/dev/xvda" # Or /dev/sda1, check your OS documentation
  volume_id   = aws_ebs_volume.primary_data.id
  instance_id = aws_instance.primary.id
}

output "primary_instance_id" {
  value = aws_instance.primary.id
  description = "ID of the primary EC2 instance"
}

output "primary_data_volume_id" {
  value = aws_ebs_volume.primary_data.id
  description = "ID of the primary EBS volume"
}