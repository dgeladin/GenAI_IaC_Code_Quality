output "primary_instance_id" {
  description = "ID of the primary EC2 instance"
  value       = aws_instance.primary.id
}

output "primary_ebs_volume_id" {
  description = "ID of the primary EBS volume"
  value       = aws_ebs_volume.primary_data.id
}

output "s3_backup_bucket_arn" {
  description = "ARN of the S3 backup bucket"
  value       = aws_s3_bucket.backup_bucket.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key for DR encryption"
  value       = aws_kms_key.dr_key.arn
}

output "lambda_function_arn" {
  description = "ARN of the DR failover Lambda function"
  value       = aws_lambda_function.dr_failover.arn
}

output "cloudwatch_event_rule_arn" {
  description = "ARN of the CloudWatch event rule for DR failover"
  value       = aws_cloudwatch_event_rule.dr_failover.arn
}

