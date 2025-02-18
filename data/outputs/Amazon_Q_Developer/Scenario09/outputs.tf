output "aws_instance_details" {
  description = "Details of the AWS EC2 instance"
  value = {
    instance_id = module.aws_resources.instance_id
    public_ip   = module.aws_resources.public_ip
    private_ip  = module.aws_resources.private_ip
    vpc_id      = module.aws_resources.vpc_id
  }
}

output "azure_vm_details" {
  description = "Details of the Azure Virtual Machine"
  value = {
    vm_id              = module.azure_resources.vm_id
    vm_name            = module.azure_resources.vm_name
    public_ip          = module.azure_resources.public_ip
    private_ip         = module.azure_resources.private_ip
    resource_group     = module.azure_resources.resource_group_name
    workspace_id       = module.azure_resources.workspace_id
  }
}

output "monitoring_details" {
  description = "Details of the monitoring configuration"
  value = {
    dashboard_url             = module.monitoring.dashboard_url
    aws_monitor_id           = module.monitoring.aws_monitor_id
    azure_monitor_id         = module.monitoring.azure_monitor_id
    multicloud_health_id     = module.monitoring.multicloud_health_monitor_id
    monitor_tags             = module.monitoring.monitor_tags
  }
}

output "infrastructure_urls" {
  description = "URLs for accessing various infrastructure components"
  value = {
    datadog_dashboard = module.monitoring.dashboard_url
    aws_console       = "https://${var.aws_region}.console.aws.amazon.com/ec2/v2/home?region=${var.aws_region}#Instances:instanceId=${module.aws_resources.instance_id}"
    azure_portal      = "https://portal.azure.com/#@${var.azure_tenant_name}/resource${module.azure_resources.vm_id}"
  }
}
