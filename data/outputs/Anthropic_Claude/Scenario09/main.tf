# main.tf

# This file serves as the entry point for our Terraform configuration
# It includes any shared resources or configurations that don't fit cleanly
# into the other specific resource files (aws.tf, azure.tf, datadog.tf, dashboard.tf)

locals {
  # Common tags to be applied to all resources that support tagging
  common_tags = merge(
    var.default_tags,
    {
      ManagedBy = "terraform"
      LastUpdated = formatdate("YYYY-MM-DD", timestamp())
    }
  )

  # Datadog tag formatting
  datadog_tags = [
    "env:${var.environment}",
    "project:multicloud-monitoring",
    "terraform:true"
  ]

  # Resource naming prefix to ensure consistency
  resource_prefix = "multicloud-${var.environment}"
}

# Any shared data sources would go here
data "aws_caller_identity" "current" {}

data "azurerm_subscription" "current" {}

# Any shared resources that don't fit in specific service files would go here
resource "datadog_tag_configuration" "aws_config" {
  provider = datadog
  source   = "aws"

  tag_config {
    tag_name           = "Environment"
    instance_tag_names = ["environment", "env"]
  }

  tag_config {
    tag_name           = "Project"
    instance_tag_names = ["project"]
  }
}

resource "datadog_tag_configuration" "azure_config" {
  provider = datadog
  source   = "azure"

  tag_config {
    tag_name           = "Environment"
    instance_tag_names = ["environment", "env"]
  }

  tag_config {
    tag_name           = "Project"
    instance_tag_names = ["project"]
  }
}

# Optional: Create a Datadog service account for the monitors
resource "datadog_service_account" "monitor_account" {
  name        = "${local.resource_prefix}-monitor-account"
  description = "Service account for managing multi-cloud monitors"

  tags = local.datadog_tags
}

# Optional: Create a Datadog role for the service account
resource "datadog_role" "monitor_role" {
  name        = "${local.resource_prefix}-monitor-role"
  description = "Role for multi-cloud monitoring service account"

  permission {
    name = "monitors_read"
  }

  permission {
    name = "monitors_write"
  }

  permission {
    name = "dashboards_read"
  }

  permission {
    name = "dashboards_write"
  }
}

# Optional: Associate the role with the service account
resource "datadog_service_account_role_association" "monitor_association" {
  service_account_id = datadog_service_account.monitor_account.id
  role_id           = datadog_role.monitor_role.id
}