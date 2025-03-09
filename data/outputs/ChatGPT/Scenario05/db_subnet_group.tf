resource "aws_db_subnet_group" "example_db_subnet_group" {
  name        = "example-db-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "Subnet group for RDS instance"
}

