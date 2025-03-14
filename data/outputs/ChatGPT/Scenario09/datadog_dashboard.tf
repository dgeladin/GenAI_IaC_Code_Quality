resource "datadog_dashboard" "multi_cloud_overview" {
  title       = "Multi-Cloud Overview"
  description = "Dashboard for monitoring CPU utilization across AWS and Azure resources."
  layout_type = "ordered"

  widget {
    timeseries_definition {
      title = "CPU Utilization (AWS & Azure)"
      show_legend = true

      request {
        q          = "avg:aws.ec2.cpu{instance_id:${aws_instance.example_ec2.id}}"
        display_type = "line"
        style {
          palette = "dog_classic"
          width   = "normal"
        }
        metadata {
          alias = "AWS EC2 CPU Usage"
        }
      }

      request {
        q          = "avg:azure.vm.percentage_cpu{resource_group:${azurerm_resource_group.example_rg.name}, vm_name:${azurerm_linux_virtual_machine.example_vm.name}}"
        display_type = "line"
        style {
          palette = "warm"
          width   = "normal"
        }
        metadata {
          alias = "Azure VM CPU Usage"
        }
      }
    }
  }
}

