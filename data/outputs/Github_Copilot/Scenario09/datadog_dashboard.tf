resource "datadog_dashboard" "multi_cloud_overview" {
  title        = "Multi-Cloud Overview"
  description  = "Dashboard to monitor CPU utilization across AWS and Azure"
  layout_type  = "ordered"
  is_read_only = false

  widget {
    title       = "CPU Utilization"
    definition {
      type = "timeseries"

      requests {
        q           = "avg:aws.ec2.cpuutilization{instance:${aws_instance.example.id}}"
        display_type = "line"
        style {
          palette = "dog_classic"
          type    = "solid"
          width   = "normal"
        }
        on_right_yaxis = false
      }

      requests {
        q           = "avg:azure.vm.percentage_cpu{resource_group:${azurerm_resource_group.example.name}, vm:${azurerm_virtual_machine.example.name}}"
        display_type = "line"
        style {
          palette = "cool"
          type    = "solid"
          width   = "normal"
        }
        on_right_yaxis = false
      }

      yaxis {
        scale = "linear"
        include_zero = true
      }
    }
  }
}