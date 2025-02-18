# Datadog Provider Configuration Validation
resource "datadog_monitor" "connectivity_check" {
  name    = "[${var.environment}] Datadog-Cloud Integration Health Check"
  type    = "service check"
  message = <<-EOT
    Datadog integration connectivity check failed for cloud platforms.
    
    Please verify:
    1. API/APP keys are valid
    2. Cloud integrations are properly configured
    3. Network connectivity is established
    
    Notify: ${var.notification_targets}
  EOT

  query = "\"datadog.agent.up\".over(\"*\").by(\"host\").last(2).count_by_status()"

  monitor_thresholds {
    warning  = 1
    critical = 1
  }

  include_tags = true
  tags        = local.common_tags
}

# AWS Integration Monitor
resource "datadog_integration_aws" "monitoring" {
  count = var.enable_aws_integration ? 1 : 0

  account_id = var.aws_account_id
  role_name  = var.aws_integration_role_name

  host_tags = local.common_tags
  
  account_specific_namespace_rules = {
    ec2       = true
    cloudwatch = true
  }
}

# Azure Integration Monitor
resource "datadog_integration_azure" "monitoring" {
  count = var.enable_azure_integration ? 1 : 0

  tenant_name = var.azure_tenant_name
  client_id   = var.azure_client_id
  client_secret = var.azure_client_secret

  host_tags = local.common_tags
}

# AWS EC2 CPU Monitor
resource "datadog_monitor" "aws_cpu" {
  name    = "[${var.environment}] AWS EC2 High CPU Usage - ${var.aws_instance_id}"
  type    = "metric alert"
  message = <<-EOT
    CPU usage is too high on AWS EC2 instance ${var.aws_instance_id}
    
    Instance details:
    * Instance ID: {{host.name}}
    * Region: ${var.aws_region}
    
    Current value: {{value}}
    
    Actions to take:
    1. Check instance metrics in AWS Console
    2. Review application logs
    3. Consider scaling if load is legitimate
    
    Notify: ${var.notification_targets}
  EOT

  query = "avg(last_5m):avg:aws.ec2.cpuutilization{instanceid:${var.aws_instance_id}} > ${var.cpu_threshold_critical}"

  monitor_thresholds {
    critical = var.cpu_threshold_critical
    warning  = var.cpu_threshold_warning
  }

  include_tags = true
  tags        = concat(local.common_tags, ["provider:aws"])

  notify_audit        = true
  timeout_h          = 0
  new_group_delay    = 300
  evaluation_delay   = 60
  renotify_interval = 60

  notify_no_data    = true
  no_data_timeframe = 10
}

# Azure VM CPU Monitor
resource "datadog_monitor" "azure_cpu" {
  name    = "[${var.environment}] Azure VM High CPU Usage - ${var.azure_vm_name}"
  type    = "metric alert"
  message = <<-EOT
    CPU usage is too high on Azure VM ${var.azure_vm_name}
    
    VM details:
    * VM Name: ${var.azure_vm_name}
    * Resource Group: ${var.azure_resource_group}
    * Location: ${var.azure_location}
    
    Current value: {{value}}
    
    Actions to take:
    1. Check VM metrics in Azure Portal
    2. Review application logs
    3. Consider scaling if load is legitimate
    
    Notify: ${var.notification_targets}
  EOT

  query = "avg(last_5m):avg:azure.vm.percentage_cpu{resource_group:${var.azure_resource_group},name:${var.azure_vm_name}} > ${var.cpu_threshold_critical}"

  monitor_thresholds {
    critical = var.cpu_threshold_critical
    warning  = var.cpu_threshold_warning
  }

  include_tags = true
  tags        = concat(local.common_tags, ["provider:azure"])

  notify_audit        = true
  timeout_h          = 0
  new_group_delay    = 300
  evaluation_delay   = 60
  renotify_interval = 60

  notify_no_data    = true
  no_data_timeframe = 10
}

# Composite Monitor for Multi-Cloud Health
resource "datadog_monitor" "multicloud_health" {
  name    = "[${var.environment}] Multi-Cloud Infrastructure Health"
  type    = "composite"
  message = <<-EOT
    Multiple cloud platforms are experiencing high CPU usage.
    
    This could indicate a broader system issue that needs immediate attention.
    
    Affected resources:
    * Check individual monitor alerts for specific instances
    
    Actions to take:
    1. Review overall system load
    2. Check for ongoing deployments or batch jobs
    3. Consider load balancing or scaling strategy
    
    Notify: ${var.notification_targets}
  EOT

  query = "${datadog_monitor.aws_cpu.id} && ${datadog_monitor.azure_cpu.id}"

  tags = concat(local.common_tags, ["service:infrastructure"])
}

# Memory Usage Monitors
resource "datadog_monitor" "memory_usage" {
  for_each = {
    aws   = { instance_id = var.aws_instance_id }
    azure = { vm_name = var.azure_vm_name, resource_group = var.azure_resource_group }
  }

  name    = "[${var.environment}] High Memory Usage - ${each.key}"
  type    = "metric alert"
  message = <<-EOT
    Memory usage is high on ${each.key} instance.
    
    Current value: {{value}}
    
    Actions to take:
    1. Check memory metrics
    2. Review application memory consumption
    3. Consider resource allocation
    
    Notify: ${var.notification_targets}
  EOT

  query = each.key == "aws" ? (
    "avg(last_5m):avg:system.mem.used{instanceid:${each.value.instance_id}} > ${var.memory_threshold_critical}"
  ) : (
    "avg(last_5m):avg:azure.vm.memory_used_percentage{resource_group:${each.value.resource_group},name:${each.value.vm_name}} > ${var.memory_threshold_critical}"
  )

  monitor_thresholds {
    critical = var.memory_threshold_critical
    warning  = var.memory_threshold_warning
  }

  include_tags = true
  tags        = concat(local.common_tags, ["provider:${each.key}"])
}

# Disk Usage Monitors
resource "datadog_monitor" "disk_usage" {
  for_each = {
    aws   = { instance_id = var.aws_instance_id }
    azure = { vm_name = var.azure_vm_name, resource_group = var.azure_resource_group }
  }

  name    = "[${var.environment}] High Disk Usage - ${each.key}"
  type    = "metric alert"
  message = <<-EOT
    Disk usage is high on ${each.key} instance.
    
    Current value: {{value}}
    
    Actions to take:
    1. Check disk usage patterns
    2. Clean up unnecessary files
    3. Consider disk expansion
    
    Notify: ${var.notification_targets}
  EOT

  query = each.key == "aws" ? (
    "avg(last_5m):avg:system.disk.used{instanceid:${each.value.instance_id}} > ${var.disk_threshold_critical}"
  ) : (
    "avg(last_5m):avg:azure.vm.disk_used_percentage{resource_group:${each.value.resource_group},name:${each.value.vm_name}} > ${var.disk_threshold_critical}"
  )

  monitor_thresholds {
    critical = var.disk_threshold_critical
    warning  = var.disk_threshold_warning
  }

  include_tags = true
  tags        = concat(local.common_tags, ["provider:${each.key}"])
}

locals {
  common_tags = concat(
    var.additional_tags,
    [
      "env:${var.environment}",
      "managed-by:terraform",
      "service:monitoring"
    ]
  )
}
