output "windows_dev_instance_ids" {
  value       = aws_instance.windows_dev.*.id
  description = "IDs of Windows instances in the dev environment"
}

output "windows_prod_instance_ids" {
  value       = aws_instance.windows_prod.*.id
  description = "IDs of Windows instances in the prod environment"
}

output "linux_dev_instance_ids" {
  value       = aws_instance.linux_dev.*.id
  description = "IDs of AWS Linux instances in the dev environment"
}

output "linux_prod_instance_ids" {
  value       = aws_instance.linux_prod.*.id
  description = "IDs of AWS Linux instances in the prod environment"
}