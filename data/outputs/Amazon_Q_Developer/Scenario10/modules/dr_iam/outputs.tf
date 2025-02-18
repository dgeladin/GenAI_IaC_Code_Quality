output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.dr_lambda_role.arn
}

output "lambda_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.dr_lambda_role.name
}

output "cross_region_role_arn" {
  description = "ARN of the cross-region access role"
  value       = aws_iam_role.dr_cross_region.arn
}

output "cross_region_role_name" {
  description = "Name of the cross-region access role"
  value       = aws_iam_role.dr_cross_region.name
}
