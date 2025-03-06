# global_accelerator/outputs.tf

output "accelerator_arn" {
  description = "The ARN of the Global Accelerator."
  value       = aws_globalaccelerator_accelerator.example.id
}
