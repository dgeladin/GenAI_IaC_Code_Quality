# Blue Launch Template
resource "aws_launch_template" "blue_lt" {
  name_prefix   = "blue-lt-"
  image_id      = "ami-0c94855ba95c574c8" # Amazon Linux 2 - Replace with your preferred AMI
  instance_type = "t3.micro"
  user_data     = base64encode("#!/bin/bash\necho \"Hello from Blue Environment\" > index.html\nsudo yum install -y python3 && nohup python3 -m http.server 80 &")

  network_interface {
    security_groups = [aws_security_group.app_sg.id]
  }

  tag {
    key = "Environment"
    value = "blue"
  }
}

# Green Launch Template
resource "aws_launch_template" "green_lt" {
  name_prefix   = "green-lt-"
  image_id      = "ami-0c94855ba95c574c8" # Amazon Linux 2 - Replace with your preferred AMI
  instance_type = "t3.micro"
  user_data     = base64encode("#!/bin/bash\necho \"Hello from Green Environment\" > index.html\nsudo yum install -y python3 && nohup python3 -m http.server 80 &")

  network_interface {
    security_groups = [aws_security_group.app_sg.id]
  }

  tag {
    key = "Environment"
    value = "green"
  }
}