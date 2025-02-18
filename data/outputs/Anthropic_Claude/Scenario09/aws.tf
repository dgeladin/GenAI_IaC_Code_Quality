# aws.tf
resource "aws_instance" "monitoring_instance" {
  ami           = var.aws_ami_id
  instance_type = var.aws_instance_type

  # Use default VPC and subnet for simplicity
  # In production, you would want to specify these
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]

  root_block_device {
    volume_size = 20
    encrypted   = true
  }

  # Enable detailed monitoring for Datadog
  monitoring = true

  tags = {
    Name = "monitoring-instance"
  }
}

resource "aws_security_group" "monitoring_sg" {
  name_prefix = "monitoring-sg"
  description = "Security group for monitoring instance"

  # Allow Datadog agent outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # We're not opening any inbound ports for this example
  # Add necessary inbound rules based on your requirements
}
