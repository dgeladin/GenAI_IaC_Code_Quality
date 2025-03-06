output "primary_instance_id" {
  description = "The ID of the primary EC2 instance"
  value       = module.primary_site.primary_instance_id
}

output "dr_bucket_name" {
  description = "The name of the DR S3 bucket"
  value       = module.dr_site.dr_bucket_name
}
