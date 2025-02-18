resource "datadog_monitor" "aws_cpu_utilization" {
  name    = "AWS EC2 CPU Utilization"
  type    = "metric alert"
  query   = "avg(last_5m):avg:aws.ec2.cpuutilization{instance:${aws_instance.example.id}} > 80"
  message = "CPU utilization on AWS EC2 instance is above 80%"

  tags = ["environment:production", "team:devops"]

  thresholds {
    critical = 80
  }
}

resource "datadog_monitor" "azure_cpu_utilization" {
  name    = "Azure VM CPU Utilization"
  type    = "metric alert"
  query   = "avg(last_5m):avg:azure.vm.percentage_cpu{resource_group:${azurerm_resource_group.example.name}, vm:${azurerm_virtual_machine.example.name}} > 80"
  message = "CPU utilization on Azure VM is above 80%"

  tags = ["environment:production", "team:devops"]

  thresholds {
    critical = 80
  }
}