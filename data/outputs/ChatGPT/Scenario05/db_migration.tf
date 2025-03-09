resource "null_resource" "db_migration" {
  triggers = {
    script_hash = sha256(data.template_file.initial_schema.rendered)
  }

  provisioner "local-exec" {
    command = <<EOT
      mysql -h ${aws_db_instance.example_db.address} \
            -u ${var.db_username} \
            -p${var.db_password} \
            myapp < ${path.module}/migrations/V1__initial_schema.sql
    EOT
  }

  depends_on = [aws_db_instance.example_db]
}

