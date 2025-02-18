output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.monitoring_instance.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.monitoring_instance.public_ip
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.monitoring_instance.private_ip
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.monitoring_vpc.id
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = aws_subnet.monitoring_subnet.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.monitoring_sg.id
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.monitoring_role.arn
}
