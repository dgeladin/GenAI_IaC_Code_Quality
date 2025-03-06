# Define the launch template
resource "aws_launch_template" "example_template" {
  name          = "example-template"
  image_id      = var.ami_id  # Variable for the AMI ID
  instance_type = var.instance_type  # Variable for the instance type

  # Additional configuration options
  key_name               = var.key_name
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile {
    name = var.iam_instance_profile
  }

  # Monitoring and other settings
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "example-instance"
    }
  }
}
