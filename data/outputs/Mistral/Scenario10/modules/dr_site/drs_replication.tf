provider "aws" {
  alias  = "dr"
  region = var.region_dr
}

data "aws_kms_key" "ebs_key" {
  provider = aws.dr
  key_id   = "alias/aws/ebs"
}

resource "aws_drs_replication_configuration_template" "example" {
  provider = aws.dr

  replication_configuration_template_id = "example-replication-template"
  default_large_staging_disk_type       = "gp3"

  replication_server_instance_type = "t3.micro"

  replication_servers_security_groups_ids = [
    aws_security_group.drs_sg.id
  ]

  staging_area_subnet_id = aws_subnet.drs_subnet.id

  associate_default_security_group = true

  use_dedicated_replication_server = false

  tags = {
    Name        = "example-replication-template"
    Environment = "dr"
  }

  ebs_encryption = {
    encrypted = true
    kms_key_id = data.aws_kms_key.ebs_key.arn
  }
}

resource "aws_security_group" "drs_sg" {
  provider = aws.dr
  name     = "drs-replication-sg"
  vpc_id   = aws_vpc.drs_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "drs-replication-sg"
    Environment = "dr"
  }
}

resource "aws_vpc" "drs_vpc" {
  provider = aws.dr
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "drs-vpc"
    Environment = "dr"
  }
}

resource "aws_subnet" "drs_subnet" {
  provider = aws.dr
  vpc_id     = aws_vpc.drs_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name        = "drs-subnet"
    Environment = "dr"
  }
}
