resource "datadog_monitor" "aws_cpu_monitor" {
  name    = "AWS EC2 High CPU Usage"
  type    = "metric alert"
  query   = "avg(last_5m):avg:aws.ec2.cpu{instance_id:${aws_instance.example_ec2.id}} > 80"
  
  message = "🚨 *AWS EC2 Instance High CPU Alert* 🚨\nThe CPU utilization for EC2 instance `${aws_instance.example_ec2.id}` has exceeded 80%.\nInvestigate immediately!"
  
  thresholds {
    critical = 80
  }

  tags = ["environment:production", "service:ec2"]
}

resource "datadog_monitor" "azure_cpu_monitor" {
  name    = "Azure VM High CPU Usage"
  type    = "metric alert"
  query   = "avg(last_5m):avg:azure.vm.percentage_cpu{resource_group:${azurerm_resource_group.example_rg.name}, vm_name:${azurerm_linux_virtual_machine.example_vm.name}} > 80"
  
  message = "🚨 *Azure VM High CPU Alert* 🚨\nThe CPU utilization for Azure VM `${azurerm_linux_virtual_machine.example_vm.name}` in resource group `${azurerm_resource_group.example_rg.name}` has exceeded 80%.\nInvestigate immediately!"
  
  thresholds {
    critical = 80
  }

  tags = ["environment:production", "service:azure-vm"]
}

