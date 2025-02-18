resource "aws_launch_template" "example" {
  name_prefix   = "${local.name_prefix}-template"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  # Network configuration
  network_interface {
    associate_public_ip_address = true
    security_groups            = [aws_security_group.instance.id]
  }

  # Instance profile
  iam_instance_profile {
    name = aws_iam_instance_profile.asg_profile.name
  }

  # Block device mappings
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type          = "gp3"
      delete_on_termination = true
      encrypted            = true
    }
  }

  # Metadata options (IMDSv2)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Monitoring
  monitoring {
    enabled = true
  }

  # User data
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y amazon-cloudwatch-agent
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:${aws_ssm_parameter.cw_agent.name}
              EOF
  )

  # Tags
  tags = local.launch_template_tags

  tag_specifications {
    resource_type = "instance"
    tags          = local.instance_tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.volume_tags
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# CloudWatch agent configuration
resource "aws_ssm_parameter" "cw_agent" {
  name  = "/${local.name_prefix}/cloudwatch-agent-config"
  type  = "String"
  value = jsonencode({
    metrics = {
      metrics_collected = {
        mem = {
          measurement = [
            "mem_used_percent"
          ]
        }
        swap = {
          measurement = [
            "swap_used_percent"
          ]
        }
      }
    }
  })

  tags = local.common_tags
}
