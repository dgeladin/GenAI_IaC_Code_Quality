# dashboard.tf

resource "datadog_dashboard" "multicloud_overview" {
  title       = "Multi-Cloud Overview"
  description = "CPU utilization overview across AWS and Azure compute resources"
  layout_type = "ordered"

  widget {
    timeseries_definition {
      title = "CPU Utilization Comparison"
      
      request {
        q = "avg:aws.ec2.cpu{instance-id:${aws_instance.monitoring_instance.id}}"
        
        display_type = "line"
        style {
          palette = "cool"
          line_type = "solid"
          line_width = "normal"
        }
        
        metadata {
          alias = "AWS EC2 CPU (%)"
        }
      }
      
      request {
        q = "avg:azure.vm.percentage_cpu{resource_group:${azurerm_resource_group.monitoring_rg.name},name:${azurerm_linux_virtual_machine.monitoring_vm.name}}"
        
        display_type = "line"
        style {
          palette = "warm"
          line_type = "solid"
          line_width = "normal"
        }
        
        metadata {
          alias = "Azure VM CPU (%)"
        }
      }

      yaxis {
        min = "0"
        max = "100"
        label = "CPU Utilization (%)"
        include_zero = true
        scale = "linear"
      }

      marker {
        display_type = "error dashed"
        value       = "y = ${var.cpu_critical_threshold}"
        label      = "Critical Threshold"
      }

      marker {
        display_type = "warning dashed"
        value       = "y = ${var.cpu_warning_threshold}"
        label      = "Warning Threshold"
      }
    }
  }

  widget {
    note_definition {
      content = <<-EOT
        ### Multi-Cloud Resource Details
        
        **AWS EC2 Instance**
        - Instance ID: ${aws_instance.monitoring_instance.id}
        - Region: ${var.aws_region}
        - Type: ${var.aws_instance_type}
        
        **Azure Virtual Machine**
        - Name: ${azurerm_linux_virtual_machine.monitoring_vm.name}
        - Resource Group: ${azurerm_resource_group.monitoring_rg.name}
        - Location: ${var.azure_location}
        - Size: ${var.azure_vm_size}
        
        **Alert Thresholds**
        - Critical: ${var.cpu_critical_threshold}%
        - Warning: ${var.cpu_warning_threshold}%
        
        _Last Updated: ${formatdate("YYYY-MM-DD", timestamp())}_
      EOT
      
      background_color = "white"
      font_size       = "14"
      text_align      = "left"
      vertical_align  = "top"
    }
  }

  widget {
    alert_graph_definition {
      title = "CPU Alert Status"
      alert_id = datadog_monitor.aws_cpu_alert.id
      viz_type = "timeseries"
    }
  }

  widget {
    alert_graph_definition {
      title = "CPU Alert Status"
      alert_id = datadog_monitor.azure_cpu_alert.id
      viz_type = "timeseries"
    }
  }
}