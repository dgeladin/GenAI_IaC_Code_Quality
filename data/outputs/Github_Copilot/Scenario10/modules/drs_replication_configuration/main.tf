data "aws_kms_key" "drs_encryption_key" {
  provider = aws.dr
  key_id   = aws_kms_key.dr_key.id
}

resource "aws_drs_replication_configuration_template" "example" {
  provider = aws.dr

  staging_area_subnet_id = "<your-subnet-id>" # Replace with your subnet ID
  staging_area_tags = {
    Name        = "drs-staging-area"
    Environment = "DR"
  }
  
  ebs_encryption = "CUSTOMER_MANAGED"
  kms_key_arn    = data.aws_kms_key.drs_encryption_key.arn

  source_server_tags = {
    Name        = "primary-instance"
    Environment = "Primary"
  }

  replication_server_instance_type = "t3.micro"
}

output "drs_replication_configuration_template_id" {
  value = aws_drs_replication_configuration_template.example.id
}