# Resource Group
resource "azurerm_resource_group" "monitoring_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = merge(
    var.default_tags,
    {
      environment = var.environment
    }
  )
}

# Virtual Network
resource "azurerm_virtual_network" "monitoring_vnet" {
  name                = "${var.environment}-monitoring-vnet"
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.monitoring_rg.location
  resource_group_name = azurerm_resource_group.monitoring_rg.name

  tags = var.default_tags
}

# Subnet
resource "azurerm_subnet" "monitoring_subnet" {
  name                 = "${var.environment}-monitoring-subnet"
  resource_group_name  = azurerm_resource_group.monitoring_rg.name
  virtual_network_name = azurerm_virtual_network.monitoring_vnet.name
  address_prefixes     = [var.subnet_cidr]
}

# Network Security Group
resource "azurerm_network_security_group" "monitoring_nsg" {
  name                = "${var.environment}-monitoring-nsg"
  location            = azurerm_resource_group.monitoring_rg.location
  resource_group_name = azurerm_resource_group.monitoring_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "22"
    source_address_prefixes   = var.allowed_ssh_cidrs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "443"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }

  tags = var.default_tags
}

# Public IP
resource "azurerm_public_ip" "monitoring_pip" {
  name                = "${var.environment}-monitoring-pip"
  location            = azurerm_resource_group.monitoring_rg.location
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  allocation_method   = "Static"
  sku                = "Standard"

  tags = var.default_tags
}

# Network Interface
resource "azurerm_network_interface" "monitoring_nic" {
  name                = "${var.environment}-monitoring-nic"
  location            = azurerm_resource_group.monitoring_rg.location
  resource_group_name = azurerm_resource_group.monitoring_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.monitoring_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.monitoring_pip.id
  }

  tags = var.default_tags
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "monitoring_nsg_association" {
  network_interface_id      = azurerm_network_interface.monitoring_nic.id
  network_security_group_id = azurerm_network_security_group.monitoring_nsg.id
}

# Managed Identity
resource "azurerm_user_assigned_identity" "monitoring_identity" {
  name                = "${var.environment}-monitoring-identity"
  location            = azurerm_resource_group.monitoring_rg.location
  resource_group_name = azurerm_resource_group.monitoring_rg.name

  tags = var.default_tags
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "monitoring_vm" {
  name                            = var.vm_name
  location                        = azurerm_resource_group.monitoring_rg.location
  resource_group_name             = azurerm_resource_group.monitoring_rg.name
  size                           = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.monitoring_nic.id
  ]

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.monitoring_identity.id]
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "StandardSSD_LRS"
    disk_size_gb          = var.os_disk_size
    disk_encryption_set_id = var.disk_encryption_set_id
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/templates/cloud-init.yaml", {
    environment = var.environment
  }))

  tags = merge(
    var.default_tags,
    {
      Name = var.vm_name
    }
  )
}

# Azure Monitor Diagnostic Setting
resource "azurerm_monitor_diagnostic_setting" "vm_diagnostics" {
  name                       = "${var.environment}-vm-diagnostics"
  target_resource_id        = azurerm_linux_virtual_machine.monitoring_vm.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.monitoring.id

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "monitoring" {
  name                = "${var.environment}-monitoring-workspace"
  location            = azurerm_resource_group.monitoring_rg.location
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  sku                = "PerGB2018"
  retention_in_days   = 30

  tags = var.default_tags
}

# VM Extension for Log Analytics
resource "azurerm_virtual_machine_extension" "monitoring_agent" {
  name                       = "OmsAgentForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.monitoring_vm.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"
  type_handler_version       = "1.13"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "workspaceId": "${azurerm_log_analytics_workspace.monitoring.workspace_id}"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "workspaceKey": "${azurerm_log_analytics_workspace.monitoring.primary_shared_key}"
    }
PROTECTED_SETTINGS

  tags = var.default_tags
}

# Azure Monitor Action Group
resource "azurerm_monitor_action_group" "monitoring" {
  name                = "${var.environment}-monitoring-action-group"
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  short_name          = "monitoring"

  email_receiver {
    name          = "admin"
    email_address = var.alert_email
  }

  tags = var.default_tags
}

# CPU Alert Rule
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "${var.environment}-cpu-alert"
  resource_group_name = azurerm_resource_group.monitoring_rg.name
  scopes              = [azurerm_linux_virtual_machine.monitoring_vm.id]
  description         = "Alert when CPU usage exceeds threshold"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.monitoring.id
  }

  tags = var.default_tags
}
