resource "datadog_dashboard" "multicloud_overview" {
  title       = "Multi-Cloud Infrastructure Overview"
  description = "Comprehensive view of AWS and Azure resources performance metrics"
  layout_type = "ordered"

  widget {
    group_definition {
      layout_type = "ordered"
      title       = "CPU Utilization"

      widget {
        timeseries_definition {
          title = "CPU Usage Comparison"
          show_legend = true
          legend_size = "auto"
          live_span   = "1h"

          request {
            q = "avg:aws.ec2.cpuutilization{instanceid:${var.aws_instance_id}}.rollup(avg, 60)"
            display_type = "line"
            style {
              palette    = "cool"
              line_type  = "solid"
              line_width = "normal"
            }
            metadata {
              alias_name = "AWS EC2 CPU"
            }
          }

          request {
            q = "avg:azure.vm.percentage_cpu{resource_group:${var.azure_resource_group},name:${var.azure_vm_name}}.rollup(avg, 60)"
            display_type = "line"
            style {
              palette    = "warm"
              line_type  = "solid"
              line_width = "normal"
            }
            metadata {
              alias_name = "Azure VM CPU"
            }
          }

          yaxis {
            label = "CPU Usage (%)"
            min   = "0"
            max   = "100"
            scale = "linear"
          }

          marker {
            display_type = "error dashed"
            value       = var.cpu_threshold_critical
            label       = "Critical Threshold"
          }
        }
      }
    }
  }

  widget {
    group_definition {
      layout_type = "ordered"
      title       = "Memory Usage"

      widget {
        timeseries_definition {
          title = "Memory Usage Comparison"
          show_legend = true
          legend_size = "auto"
          live_span   = "1h"

          request {
            q = "avg:system.mem.used{instanceid:${var.aws_instance_id}}.rollup(avg, 60)"
            display_type = "line"
          }

          request {
            q = "avg:azure.vm.memory_used_percentage{resource_group:${var.azure_resource_group},name:${var.azure_vm_name}}.rollup(avg, 60)"
            display_type = "line"
          }
        }
      }
    }
  }

  widget {
    group_definition {
      layout_type = "ordered"
      title       = "Disk Usage"

      widget {
        timeseries_definition {
          title = "Disk Usage Comparison"
          show_legend = true
          legend_size = "auto"
          live_span   = "1h"

          request {
            q = "avg:system.disk.used{instanceid:${var.aws_instance_id}}.rollup(avg, 60)"
            display_type = "line"
          }

          request {
            q = "avg:azure.vm.disk_used_percentage{resource_group:${var.azure_resource_group},name:${var.azure_vm_name}}.rollup(avg, 60)"
            display_type = "line"
          }
        }
      }
    }
  }

  widget {
    alert_graph_definition {
      title = "Recent Alert Status"
      alert_id = datadog_monitor.multicloud_health.id
      viz_type = "timeseries"
    }
  }

  template_variable {
    name    = "env"
    default = var.environment
    prefix  = "env"
  }

  template_variable {
    name    = "timeframe"
    default = "1h"
    prefix  = "timeframe"
  }
}
