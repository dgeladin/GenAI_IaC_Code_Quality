# global_accelerator/main.tf

resource "aws_globalaccelerator_accelerator" "example" {
  name            = "example-accelerator"
  ip_address_type = "IPV4"
  enabled         = true
}

resource "aws_globalaccelerator_listener" "example" {
  accelerator_arn = aws_globalaccelerator_accelerator.example.id
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }

  client_affinity = "SOURCE_IP"
}

resource "aws_globalaccelerator_endpoint_group" "example" {
  listener_arn = aws_globalaccelerator_listener.example.id

  dynamic "endpoint_configuration" {
    for_each = var.endpoint_ids
    content {
      endpoint_id = endpoint_configuration.value
      weight      = 50
    }
  }
}
