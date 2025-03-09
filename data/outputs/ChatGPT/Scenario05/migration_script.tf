data "template_file" "initial_schema" {
  template = file("${path.module}/migrations/V1__initial_schema.sql")
}

