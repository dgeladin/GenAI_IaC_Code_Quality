# drs_replication.tf

resource "aws_drs_replication_configuration_template" "drs_template" {
  name                                   = "drs-replication-template"
  instance_type                          = "t3.micro" # Must match source instance type
  security_group_ids                     = [aws_security_group.drs_sg.id] # Use the security group created below
  subnet_ids                             = [aws_subnet.drs_subnet.id] # Use the subnet created below
  ebs_encryption                         = "ENABLED"
  ebs_encryption_key_arn                 = aws_kms_key.dr_key.arn  # Reference the KMS key
  export_bucket_name                     = aws_s3_bucket.drs_export_bucket.id # Replace with a bucket in DR region for launch details
  tags = {
    Name        = "drs-replication-template"
    Environment = "dr"
  }

  point_in_time_recovery {
    status = "ENABLED"
  }
}

resource "aws_drs_launch_configuration" "drs_launch_config" {
  source_server_id = aws_drs_source_server.drs_source_server.id
  target_instance_type = "t3.micro"
  ec2_instance_type = "t3.micro"
  replication_configuration_template_arn = aws_drs_replication_configuration_template.drs_template.arn
  security_group_ids = [aws_security_group.drs_sg.id]
  subnet_id = aws_subnet.drs_subnet.id
}

resource "aws_drs_source_server" "drs_source_server" {
  source_properties {
    cpus {
      count = 1 # Number of CPUs on source instance
    }
    disks {
      size_bytes = aws_ebs_volume.primary_data.size * 1024 * 1024
      raw_bytes = aws_ebs_volume.primary_data.size * 1024 * 1024
      iops = 3000 # IOPS of the source volume
      throughput = 125 # Throughput of the source volume
      type = "gp3" # Type of the source volume
    }
    identifier = aws_instance.primary.id
    instance_type = aws_instance.primary.instance_type
    memory_mib = 1024 # Memory in MiB on source instance
    os {
      full_string = "Amazon Linux 2" # Example OS, use your OS details.
    }
    tags = {
      Name        = "drs-source-server"
      Environment = "primary"
    }
  }

  replication_configuration_template_arn = aws_drs_replication_configuration_template.drs_template.arn
}

output "drs_template_arn" {
  value = aws_drs_replication_configuration_template.drs_template.arn
  description = "ARN of the DRS replication configuration template"
}

output "drs_source_server_id" {
  value = aws_drs_source_server.drs_source_server.id
  description = "ID of the DRS Source Server"
}


# Example Security Group and Subnet (Add these to your network configuration files)
resource "aws_security_group" "drs_sg" {
  name        = "drs-sg"
  description = "Security group for DRS replicated instances"
  vpc_id = aws_vpc.main.id # Replace with your VPC ID

  tags = {
    Name = "drs-sg"
  }
}

resource "aws_subnet" "drs_subnet" {
  vpc_id                  = aws_vpc.main.id # Replace with your VPC ID
  cidr_block              = "10.0.2.0/24" # Replace with your desired CIDR block
  availability_zone = "us-east-1a" # Replace with your desired Availability Zone

  tags = {
    Name = "drs-subnet"
  }
}

resource "aws_s3_bucket" "drs_export_bucket" {
  bucket = "drs-export-bucket-us-east-1" # Choose a unique name
  region = "us-east-1"

  tags = {
    Name = "drs-export-bucket"
  }
}

# Add VPC resource
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}