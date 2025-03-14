resource "aws_drs_replication_configuration_template" "example" {
  provider                          = aws.dr
  staging_area_subnet_id            = "subnet-12345678"  # Replace with actual subnet ID
  associate_default_security_group  = true
  default_large_staging_disk_type   = "GP3"
  ebs_encryption                    = "CUSTOMER_MANAGED"
  ebs_encryption_key_arn            = aws_kms_key.dr_key.arn
  pit_policy_enabled                = true

  tags = {
    Name        = "example-drs-replication"
    Environment = "disaster-recovery"
  }
}

