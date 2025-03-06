output "network_details" {
  description = "Details about the network infrastructure."
  value       = module.network.network_details
}

output "compute_details" {
  description = "Details about the compute infrastructure."
  value       = module.compute.compute_details
}

output "database_details" {
  description = "Details about the database infrastructure."
  value       = module.database.database_details
}
