# Providers configuration
provider "aws" {
  region = "us-east-1"
}

provider "azurerm" {
  features {}
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

# AWS EC2 Instance
resource "aws_instance" "example" {
  ami           = var.aws_ami
  instance_type = var.aws_instance_type

  tags = {
    Name        = "example-instance"
    Environment = var.environment
  }
}

# Azure Resource Group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = var.azure_location
}

# Azure Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Azure Subnet
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Azure Network Interface
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Azure Virtual Machine
resource "azurerm_virtual_machine" "example" {
  name                  = "example-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = var.azure_vm_size

  storage_os_disk {
    name              = "example-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "example-vm"
    admin_username = var.azure_admin_username
    admin_password = var.azure_admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    Name        = "example-vm"
    Environment = var.environment
  }
}

# Datadog Monitor for AWS EC2 CPU Utilization
resource "datadog_monitor" "aws_cpu_alert" {
  name               = "AWS EC2 CPU Utilization Alert"
  type               = "metric alert"
  query              = "avg(last_5m):avg:aws.ec2.cpuutilization{host:${aws_instance.example.id}} > 80"
  message            = "CPU utilization is high on AWS EC2 instance {{host.name}}"
  tags               = ["environment:${var.environment}"]
  thresholds {
    critical = 80
  }
}

# Datadog Monitor for Azure VM CPU Utilization
resource "datadog_monitor" "azure_cpu_alert" {
  name               = "Azure VM CPU Utilization Alert"
  type               = "metric alert"
  query              = "avg(last_5m):avg:azure.vm.percentage_cpu{resource_group:example-resources,name:example-vm} > 80"
  message            = "CPU utilization is high on Azure VM {{name.name}}"
  tags               = ["environment:${var.environment}"]
  thresholds {
    critical = 80
  }
}

# Datadog Dashboard for Multi-Cloud Overview
resource "datadog_dashboard" "multi_cloud_overview" {
  title        = "Multi-Cloud Overview"
  description  = "Dashboard to visualize CPU usage across AWS and Azure resources"
  layout_type  = "ordered"
  widgets      = [
    {
      "definition": {
        "type": "timeseries",
        "requests": [
          {
            "q": "avg:aws.ec2.cpuutilization{host:${aws_instance.example.id}}",
            "display_type": "line",
            "style": {
              "palette": "dog_classic",
              "type": "solid",
              "width": "normal"
            },
            "metadata": {
              "expression": "avg:aws.ec2.cpuutilization{host:${aws_instance.example.id}}"
            }
          },
          {
            "q": "avg:azure.vm.percentage_cpu{resource_group:example-resources,name:example-vm}",
            "display_type": "line",
            "style": {
              "palette": "cool",
              "type": "solid",
              "width": "normal"
            },
            "metadata": {
              "expression": "avg:azure.vm.percentage_cpu{resource_group:example-resources,name:example-vm}"
            }
          }
        ],
        "title": "CPU Usage Across Clouds"
      }
    }
  ]
}
