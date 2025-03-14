# launch_templates.tf
resource "aws_launch_template" "blue_lt" {
  name_prefix   = "blue-lt"
  image_id      = "ami-12345678"  # Replace with the latest Amazon Linux 2 AMI
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
echo "Hello from Blue Environment" > index.html
sudo yum install -y python3 && nohup python3 -m http.server 80 &
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Environment = "blue"
    }
  }
}

resource "aws_launch_template" "green_lt" {
  name_prefix   = "green-lt"
  image_id      = "ami-12345678"  # Replace with the latest Amazon Linux 2 AMI
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
echo "Hello from Green Environment" > index.html
sudo yum install -y python3 && nohup python3 -m http.server 80 &
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Environment = "green"
    }
  }
}
