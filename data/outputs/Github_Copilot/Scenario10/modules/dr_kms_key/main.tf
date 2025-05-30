resource "aws_kms_key" "dr_key" {
  provider = aws.dr

  description             = "KMS key for encrypting DR data"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "dr-encryption-key"
    Environment = "DR"
  }
}

output "kms_key_id" {
  value = aws_kms_key.dr_key.id
}

output "kms_key_arn" {
  value = aws_kms_key.dr_key.arn
}