# filename: kms.tf

# KMS key for DR encryption
resource "aws_kms_key" "dr_key" {
  provider = aws.dr_region

  description             = "KMS key for DR data encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow S3 Service"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow DRS Service"
        Effect = "Allow"
        Principal = {
          Service = "drs.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.common_tags
}

# KMS alias
resource "aws_kms_alias" "dr_key_alias" {
  provider = aws.dr_region
  
  name          = "alias/dr-encryption-key"
  target_key_id = aws_kms_key.dr_key.key_id
}

# Output the KMS key ARN
output "dr_kms_key_arn" {
  description = "ARN of the KMS key used for DR encryption"
  value       = aws_kms_key.dr_key.arn
}