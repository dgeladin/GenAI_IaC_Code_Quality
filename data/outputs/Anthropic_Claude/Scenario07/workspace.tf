# Root module - workspace.tf

# This file contains logic to ensure the correct workspace is selected

resource "null_resource" "workspace_check" {
  # This will cause Terraform to fail if the workspace is not one of the allowed values
  lifecycle {
    precondition {
      condition     = contains(["dev", "staging", "prod"], terraform.workspace)
      error_message = "The current workspace (${terraform.workspace}) is not one of the allowed values: dev, staging, prod."
    }
  }
}

# Ensure we're using the named workspaces and not 'default'
resource "null_resource" "prevent_default_workspace" {
  lifecycle {
    precondition {
      condition     = terraform.workspace != "default"
      error_message = "The 'default' workspace should not be used. Please use 'dev', 'staging', or 'prod' workspace."
    }
  }
}