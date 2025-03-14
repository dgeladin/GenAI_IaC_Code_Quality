resource "aws_kms_key" "dr_key" {
  provider                = aws.dr
  description             = "KMS key for encrypting DR data"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "dr-key"
    Environment = "disaster-recovery"
  }
}

resource "aws_kms_alias" "dr_key_alias" {
  provider      = aws.dr
  name          = "alias/dr-key"
  target_key_id = aws_kms_key.dr_key.id
}

