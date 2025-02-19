# ../modules/network/main.tf

variable "region" {
  type = string
  description = "AWS region"
  default = "us-east-1" # Example default, adjust as needed
}

variable "environment" {
  type = string
  description = "Deployment environment (development, staging, production)"
}

variable "availability_zones" {
  type = list(string)
  description = "List of availability zones"
  default = ["us-east-1a", "us-east-1b"] # Ensure at least two AZs
}

variable "public_subnet_cidrs" {
  type = list(string)
  description = "CIDR blocks for public subnets"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type = list(string)
  description = "CIDR blocks for private subnets"
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "database_port" {
  type = number
  description = "Database port"
  default = 5432 # PostgreSQL default
}


resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  count = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]

  tags = {
    Name        = "${var.environment}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "public"
  }
}

resource "aws_subnet" "private" {
  count = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]

  tags = {
    Name        = "${var.environment}-private-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "private"
  }
}


resource "aws_security_group" "web_server" {
  name        = "${var.environment}-web-server-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In real-world, restrict this!
    description = "HTTP traffic"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In real-world, restrict this!
    description = "HTTPS traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = var.environment
    Environment = var.environment
  }
}


output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "web_server_sg_id" {
  value = aws_security_group.web_server.id
}

# The database_sg_id will be provided by the database module, 
# but we can't reference it here yet. It will be passed in.