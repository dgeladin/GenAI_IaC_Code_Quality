output "s3_backup_bucket_name" {
  value = module.s3_backup_bucket.bucket_name
}

output "primary_instance_id" {
  value = module.primary_instance_and_volume.primary_instance_id
}

output "primary_data_volume_id" {
  value = module.primary_instance_and_volume.primary_data_volume_id
}

output "drs_replication_configuration_template_id" {
  value = module.drs_replication_configuration.drs_replication_configuration_template_id
}

output "kms_key_id" {
  value = module.dr_kms_key.kms_key_id
}

output "kms_key_arn" {
  value = module.dr_kms_key.kms_key_arn
}

output "cloudwatch_event_rule_arn" {
  value = module.cloudwatch_event_rule.event_rule_arn
}

output "iam_role_arn" {
  value = module.dr_lambda_iam_role.iam_role_arn
}

output "lambda_function_arn" {
  value = module.lambda_function.lambda_function_arn
}