# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    datadog = {
      source  = "datadog/datadog"
      version = "~> 3.0"
    }
  }
}

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
resource "aws_instance" "example_ec2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  tags = {
    Name = "example-ec2"
  }
}

# Azure Resources
resource "azurerm_resource_group" "example_rg" {
  name     = "example-resources"
  location = "EastUS"
}

resource "azurerm_virtual_machine" "example_vm" {
  name                  = "example-vm"
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = azurerm_resource_group.example_rg.location
  vm_size             = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-Server-Ubuntu"
    sku       = "UbuntuServer"
    version   = "latest"
  }

  storage_os_disk {
    name          = "osdisk1"
    caching       = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  network_interface_ids = [azurerm_network_interface.example_nic.id]

  os_profile {
    computer_name  = "example-vm"
    admin_username = "adminuser"
    admin_password = random_password.vm_password.result
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.example_sa.primary_blob_endpoint
  }

  tags = {
    Name = "example-vm"
  }
}

resource "azurerm_network_interface" "example_nic" {
  name                = "example-nic"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_network" "example_vnet" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
}

resource "azurerm_subnet" "example_subnet" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example_rg.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_storage_account" "example_sa" {
  name                     = "examplestorageaccount123" # Must be globally unique
  resource_group_name      = azurerm_resource_group.example_rg.name
  location                 = azurerm_resource_group.example_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_password" "vm_password" {
  length = 16
  special = true
}


# Datadog Monitors
resource "datadog_monitor" "aws_cpu_monitor" {
  name               = "AWS EC2 CPU Utilization"
  type               = "metric alert"
  query              = "avg:aws.ec2.cpu{instance:${aws_instance.example_ec2.id}} > 80"
  message            = "AWS EC2 instance ${aws_instance.example_ec2.id} CPU utilization is above 80%!"
  escalation_message = "AWS EC2 instance ${aws_instance.example_ec2.id} CPU utilization has been above 80% for 5 minutes!"

  critical {
    threshold = 80
  }

  tags = ["cloud:aws", "metric:cpu"]
}

resource "datadog_monitor" "azure_cpu_monitor" {
  name               = "Azure VM CPU Utilization"
  type               = "metric alert"
  query              = "avg:azure.vm.percentage_cpu{resource_group:${azurerm_resource_group.example_rg.name},name:${azurerm_virtual_machine.example_vm.name}} > 80"
  message            = "Azure VM ${azurerm_virtual_machine.example_vm.name} in resource group ${azurerm_resource_group.example_rg.name} CPU utilization is above 80%!"
  escalation_message = "Azure VM ${azurerm_virtual_machine.example_vm.name} in resource group ${azurerm_resource_group.example_rg.name} CPU utilization has been above 80% for 5 minutes!"

  critical {
    threshold = 80
  }

  tags = ["cloud:azure", "metric:cpu"]
}

# Datadog Dashboard
resource "datadog_dashboard" "multi_cloud_dashboard" {
  title       = "Multi-Cloud Overview"
  description = "Dashboard to visualize CPU usage across AWS and Azure"
  layout_type = "ordered"

  widget {
    type = "timeseries"

    definition {
      title = "CPU Utilization"

      yaxis {
        min = "0"
        max = "100"
        label = "Percentage"
      }

      request {
        display_type = "line"
        query        = "avg:aws.ec2.cpu{instance:${aws_instance.example_ec2.id}}"
        name = "AWS EC2 CPU"
      }

      request {
        display_type = "line"
        query        = "avg:azure.vm.percentage_cpu{resource_group:${azurerm_resource_group.example_rg.name},name:${azurerm_virtual_machine.example_vm.name}}"
        name = "Azure VM CPU"
      }
    }
  }
}

# Output Datadog Dashboard URL
output "datadog_dashboard_url" {
  value = "https://app.datadoghq.com/dashboard/${datadog_dashboard.multi_cloud_dashboard.id}"
  description = "URL to access the Datadog Multi-Cloud Overview dashboard"
}