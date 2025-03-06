provider "aws" {
  alias  = "dr"
  region = var.region_dr
}

resource "aws_kms_key" "dr_key" {
  provider                = aws.dr
  description             = "KMS key for encrypting data replicated to the DR region"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "dr-key"
    Environment = "dr"
  }
}

resource "aws_kms_alias" "dr_key_alias" {
  provider = aws.dr
  name     = "alias/dr-key"
  target_key_id = aws_kms_key.dr_key.key_id
}
