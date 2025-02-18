output "instance_id" {
  description = "ID of the primary instance"
  value       = aws_instance.primary.id
}

output "instance_private_ip" {
  description = "Private IP of the primary instance"
  value       = aws_instance.primary.private_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.primary.id
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.primary.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = aws_kms_key.primary.arn
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.primary.dashboard_name
}
