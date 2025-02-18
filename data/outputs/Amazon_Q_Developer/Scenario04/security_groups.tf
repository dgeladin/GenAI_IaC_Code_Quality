# Security Group for Load Balancer
resource "aws_security_group" "lb_sg" {
  name_prefix = "${var.environment}-lb-sg"
  description = "Security group for load balancer"
  vpc_id      = module.vpc.vpc_id

  # Inbound rule for HTTP from VPC CIDR
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow HTTP from VPC CIDR"
  }

  # Inbound rule for HTTPS from VPC CIDR
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow HTTPS from VPC CIDR"
  }

  # Inbound rule for test listener
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow test port from VPC CIDR"
  }

  # Outbound rule to application security group
  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
    description     = "Allow outbound HTTP to application instances"
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-lb-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for Application Instances
resource "aws_security_group" "app_sg" {
  name_prefix = "${var.environment}-app-sg"
  description = "Security group for application instances"
  vpc_id      = module.vpc.vpc_id

  # Inbound rule from load balancer security group
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
    description     = "Allow HTTP from load balancer"
  }

  # Inbound rule for health checks
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
    description     = "Allow health checks from load balancer"
  }

  # Outbound rule to VPC CIDR
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow all outbound traffic to VPC CIDR"
  }

  # Outbound rule for software updates
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound for updates"
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-app-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}
