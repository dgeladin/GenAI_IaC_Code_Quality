# azure.tf
resource "azurerm_resource_group" "monitoring_rg" {
  name     = var.azure_resource_group_name
  location = var.azure_location
}

resource "azurerm_virtual_network" "monitoring_vnet" {
  name                = "monitoring-vnet"
  address_space       = ["10.0.0.0/16"]
  location           = azurerm_resource_group.monitoring_rg.location
  resource_group_name = azurerm_resource_group.monitoring_rg.name
}

resource "azurerm_subnet" "monitoring_subnet" {
  name                 = "monitoring-subnet"
  resource_group_name  = azurerm_resource_group.monitoring_rg.name
  virtual_network_name = azurerm_virtual_network.monitoring_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "monitoring_nic" {
  name                = "monitoring-nic"
  location           = azurerm_resource_group.monitoring_rg.location
  resource_group_name = azurerm_resource_group.monitoring_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.monitoring_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "monitoring_vm" {
  name                = var.azure_vm_name
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  location           = azurerm_resource_group.monitoring_rg.location
  size               = var.azure_vm_size
  admin_username     = var.azure_admin_username

  network_interface_ids = [
    azurerm_network_interface.monitoring_nic.id,
  ]

  admin_ssh_key {
    username   = var.azure_admin_username
    public_key = var.azure_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}