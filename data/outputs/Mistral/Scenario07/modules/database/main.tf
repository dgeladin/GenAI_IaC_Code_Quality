resource "aws_db_instance" "main" {
  allocated_storage    = var.db_allocated_storage
  engine               = "postgres"
  engine_version       = "13"
  instance_class       = var.db_instance_class
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  port                 = var.db_port
  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_security_group_id]
  skip_final_snapshot  = true

  tags = {
    Name        = "${var.environment}-db-instance"
    Environment = var.environment
  }
}
