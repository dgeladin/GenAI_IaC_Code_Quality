# filename: drs_replication.tf

# DRS Source Server configuration
resource "aws_drs_source_server" "primary" {
  provider = aws.dr_region
  
  source_server_id = aws_instance.primary.id
  
  staging_area_subnet_id = var.dr_subnet_id
  
  tags = merge(
    var.common_tags,
    {
      Name = "Primary-DRS-Source"
    }
  )
}

# DRS Replication Configuration Template
resource "aws_drs_replication_configuration_template" "example" {
  provider = aws.dr_region
  
  associate_default_security_group = true
  bandwidth_throttling            = 100
  create_public_ip               = false
  data_plane_routing            = "PRIVATE_IP"
  ebs_encryption                = true
  ebs_encryption_key_arn        = aws_kms_key.dr_key.arn
  
  replication_server_instance_type = var.instance_type
  
  source_server_id = aws_drs_source_server.primary.id

  tags = merge(
    var.common_tags,
    {
      Name = "Primary-DRS-Config"
    }
  )
}