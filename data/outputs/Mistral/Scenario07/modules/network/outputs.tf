output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets."
  value       = aws_subnet.private[*].id
}

output "web_server_sg_id" {
  description = "The ID of the web server security group."
  value       = aws_security_group.web_server_sg.id
}

output "database_sg_id" {
  description = "The ID of the database security group."
  value       = aws_security_group.database_sg.id
}
