# filename: outputs.tf

output "primary_instance_id" {
  description = "ID of the primary EC2 instance"
  value       = aws_instance.primary.id
}

output "primary_instance_az" {
  description = "Availability Zone of the primary EC2 instance"
  value       = aws_instance.primary.availability_zone
}

output "dr_bucket_name" {
  description = "Name of the DR backup S3 bucket"
  value       = aws_s3_bucket.dr_backup.id
}

output "dr_bucket_arn" {
  description = "ARN of the DR backup S3 bucket"
  value       = aws_s3_bucket.dr_backup.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = aws_kms_key.dr_key.arn
}

output "kms_key_alias" {
  description = "Alias of the KMS key"
  value       = aws_kms_alias.dr_key_alias.name
}

output "lambda_function_arn" {
  description = "ARN of the DR failover Lambda function"
  value       = aws_lambda_function.dr_failover.arn
}

output "cloudwatch_rule_arn" {
  description = "ARN of the CloudWatch event rule"
  value       = aws_cloudwatch_event_rule.dr_failover.arn
}

output "drs_configuration_id" {
  description = "ID of the DRS replication configuration"
  value       = aws_drs_replication_configuration_template.example.id
}