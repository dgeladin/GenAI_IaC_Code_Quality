# kms_key.tf

resource "aws_kms_key" "dr_key" {
  description             = "KMS key for DR encryption"
  deletion_window_in_days = 10
  enable_key_rotation = true

  tags = {
    Name        = "dr-kms-key"
    Environment = "dr"
  }
}

output "dr_kms_key_arn" {
  value = aws_kms_key.dr_key.arn
  description = "ARN of the KMS key for DR encryption"
}