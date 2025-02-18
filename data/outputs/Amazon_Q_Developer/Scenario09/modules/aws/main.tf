# VPC Configuration
resource "aws_vpc" "monitoring_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-monitoring-vpc"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "monitoring_igw" {
  vpc_id = aws_vpc.monitoring_vpc.id

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-monitoring-igw"
    }
  )
}

# Public Subnet
resource "aws_subnet" "monitoring_subnet" {
  vpc_id                  = aws_vpc.monitoring_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-monitoring-subnet"
    }
  )
}

# Route Table
resource "aws_route_table" "monitoring_rt" {
  vpc_id = aws_vpc.monitoring_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.monitoring_igw.id
  }

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-monitoring-rt"
    }
  )
}

# Route Table Association
resource "aws_route_table_association" "monitoring_rta" {
  subnet_id      = aws_subnet.monitoring_subnet.id
  route_table_id = aws_route_table.monitoring_rt.id
}

# Security Group
resource "aws_security_group" "monitoring_sg" {
  name_prefix = "${var.environment}-monitoring-sg"
  description = "Security group for monitoring instance"
  vpc_id      = aws_vpc.monitoring_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr_blocks
    description = "SSH access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-monitoring-sg"
    }
  )
}

# IAM Role for EC2
resource "aws_iam_role" "monitoring_role" {
  name = "${var.environment}-monitoring-role"

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

  tags = var.default_tags
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "monitoring_profile" {
  name = "${var.environment}-monitoring-profile"
  role = aws_iam_role.monitoring_role.name
}

# IAM Role Policy for Systems Manager
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EC2 Instance
resource "aws_instance" "monitoring_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.monitoring_subnet.id

  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.monitoring_profile.name

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted            = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # Enforce IMDSv2
  }

  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh", {
    environment = var.environment
    region      = var.aws_region
  }))

  depends_on = [
    aws_internet_gateway.monitoring_igw
  ]

  tags = merge(
    var.default_tags,
    {
      Name = "${var.environment}-monitoring-instance"
    }
  )
}

# CloudWatch Alarm for CPU Utilization
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "${var.environment}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors EC2 CPU utilization"
  
  dimensions = {
    InstanceId = aws_instance.monitoring_instance.id
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions

  tags = var.default_tags
}
