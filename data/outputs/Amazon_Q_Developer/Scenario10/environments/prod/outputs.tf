output "primary_instance_id" {
  description = "ID of the primary EC2 instance"
  value       = module.primary_instance.instance_id
}

output "primary_instance_private_ip" {
  description = "Private IP of the primary EC2 instance"
  value       = module.primary_instance.instance_private_ip
}

output "backup_bucket_name" {
  description = "Name of the DR backup S3 bucket"
  value       = module.dr_backup.bucket_id
}

output "dr_lambda_function_arn" {
  description = "ARN of the DR failover Lambda function"
  value       = module.dr_lambda.function_arn
}

output "dr_sns_topic_arn" {
  description = "ARN of the DR notifications SNS topic"
  value       = aws_sns_topic.dr_notifications.arn
}

output "event_rule_arn" {
  description = "ARN of the DR failover event rule"
  value       = module.dr_events.rule_arn
}

output "drs_template_id" {
  description = "ID of the DRS replication template"
  value       = module.drs_config.replication_template_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = module.dr_kms.key_arn
}
