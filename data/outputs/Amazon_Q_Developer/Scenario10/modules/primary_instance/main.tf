# Primary EC2 Instance
resource "aws_instance" "primary" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.primary.id]
  iam_instance_profile   = aws_iam_instance_profile.primary.name
  
  root_block_device {
    volume_type           = var.volume_type
    volume_size           = var.volume_size
    encrypted            = true
    kms_key_id           = aws_kms_key.primary.arn
    delete_on_termination = false
    
    tags = merge(
      var.tags,
      {
        Name = "${var.environment}-primary-root-volume"
      }
    )
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh", {
    environment = var.environment
    region      = data.aws_region.current.name
  }))

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = var.environment == "prod" ? true : false
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-primary-instance"
    }
  )
}

# Security Group
resource "aws_security_group" "primary" {
  name        = "${var.environment}-primary-sg"
  description = "Security group for primary instance"
  vpc_id      = var.vpc_id

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = var.environment == "prod" ? true : false
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-primary-sg"
    }
  )
}

# Security Group Rules
resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.primary.id
}

# Add ingress rules based on var.ingress_rules
resource "aws_security_group_rule" "ingress" {
  for_each = { for rule in var.ingress_rules : "${rule.from_port}-${rule.to_port}-${rule.protocol}" => rule }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = aws_security_group.primary.id
  description       = each.value.description
}

# KMS Key for EBS encryption
resource "aws_kms_key" "primary" {
  description             = "KMS key for primary instance EBS volumes"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow DRS to use the key"
        Effect = "Allow"
        Principal = {
          Service = "drs.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-primary-kms"
    }
  )
}

# KMS Alias
resource "aws_kms_alias" "primary" {
  name          = "alias/${var.environment}-primary-key"
  target_key_id = aws_kms_key.primary.key_id
}

# IAM Role
resource "aws_iam_role" "primary" {
  name = "${var.environment}-primary-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "primary" {
  name = "${var.environment}-primary-profile"
  role = aws_iam_role.primary.name
}

# IAM Role Policies
resource "aws_iam_role_policy" "ssm_policy" {
  name = "${var.environment}-primary-ssm-policy"
  role = aws_iam_role.primary.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "instance_status" {
  alarm_name          = "${var.environment}-primary-status"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period             = "60"
  statistic          = "Maximum"
  threshold          = "0"
  alarm_description  = "Status check failed for primary instance"
  alarm_actions      = var.alarm_actions

  dimensions = {
    InstanceId = aws_instance.primary.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-primary-status-alarm"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "${var.environment}-primary-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = var.cpu_threshold
  alarm_description  = "CPU utilization exceeded threshold"
  alarm_actions      = var.alarm_actions

  dimensions = {
    InstanceId = aws_instance.primary.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-primary-cpu-alarm"
    }
  )
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "primary" {
  dashboard_name = "${var.environment}-primary-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.primary.id],
            ["AWS/EC2", "StatusCheckFailed", "InstanceId", aws_instance.primary.id],
            ["AWS/EC2", "NetworkIn", "InstanceId", aws_instance.primary.id],
            ["AWS/EC2", "NetworkOut", "InstanceId", aws_instance.primary.id]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Primary Instance Metrics"
        }
      }
    ]
  })
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
