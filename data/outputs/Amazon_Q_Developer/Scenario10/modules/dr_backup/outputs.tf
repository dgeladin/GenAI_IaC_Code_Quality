output "bucket_id" {
  description = "ID of the backup S3 bucket"
  value       = aws_s3_bucket.dr_backup.id
}

output "bucket_arn" {
  description = "ARN of the backup S3 bucket"
  value       = aws_s3_bucket.dr_backup.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for bucket encryption"
  value       = aws_kms_key.dr_backup.arn
}

output "kms_key_id" {
  description = "ID of the KMS key used for bucket encryption"
  value       = aws_kms_key.dr_backup.key_id
}

output "replication_role_arn" {
  description = "ARN of the IAM role used for S3 replication"
  value       = aws_iam_role.replication.arn
}
