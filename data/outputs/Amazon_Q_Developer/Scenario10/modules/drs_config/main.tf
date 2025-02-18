# DRS Replication Configuration
resource "aws_drs_replication_configuration_template" "dr_template" {
  associate_default_security_group = false
  bandwidth_throttling            = var.bandwidth_throttling
  create_public_ip               = false
  data_plane_routing            = "PRIVATE_IP"
  default_large_staging_disk_type = "GP3"
  ebs_encryption                = true
  enable_volume_encryption      = true
  
  replication_server_instance_type = var.replication_instance_type
  
  replication_servers_security_groups_ids = var.security_group_ids
  
  staging_area_subnet_id = var.subnet_id
  
  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-replication-template"
      Purpose = "disaster-recovery"
    }
  )
}

# DRS Source Server Configuration
resource "aws_drs_source_server" "primary" {
  source_server_id = var.source_server_id
  
  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-source-server"
      Purpose = "disaster-recovery"
    }
  )
}

# DRS Recovery Instance Configuration
resource "aws_drs_recovery_instance" "dr_instance" {
  source_server_id = aws_drs_source_server.primary.id
  
  recovery_instance_properties {
    instance_type = var.recovery_instance_type
    subnet_id     = var.subnet_id
    
    security_group_ids = var.security_group_ids
    
    volume_encrypted = true
    kms_key_id      = var.kms_key_arn
  }

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-recovery-instance"
      Purpose = "disaster-recovery"
    }
  )
}

# CloudWatch Alarms for DRS monitoring
resource "aws_cloudwatch_metric_alarm" "replication_lag" {
  alarm_name          = "${var.environment}-drs-replication-lag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "ReplicationLag"
  namespace           = "AWS/DRS"
  period             = "300"
  statistic          = "Average"
  threshold          = var.replication_lag_threshold
  alarm_description  = "DRS replication lag exceeds threshold"
  alarm_actions      = [var.sns_topic_arn]
  ok_actions         = [var.sns_topic_arn]

  dimensions = {
    SourceServerID = aws_drs_source_server.primary.id
  }

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-drs-replication-lag-alarm"
      Purpose = "monitoring"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "replication_status" {
  alarm_name          = "${var.environment}-drs-replication-status"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ReplicationStatus"
  namespace           = "AWS/DRS"
  period             = "300"
  statistic          = "Maximum"
  threshold          = "1"
  alarm_description  = "DRS replication status indicates failure"
  alarm_actions      = [var.sns_topic_arn]
  ok_actions         = [var.sns_topic_arn]

  dimensions = {
    SourceServerID = aws_drs_source_server.primary.id
  }

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-drs-replication-status-alarm"
      Purpose = "monitoring"
    }
  )
}

# CloudWatch Dashboard for DRS metrics
resource "aws_cloudwatch_dashboard" "drs_monitoring" {
  dashboard_name = "${var.environment}-drs-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/DRS", "ReplicationLag", "SourceServerID", aws_drs_source_server.primary.id],
            ["AWS/DRS", "DataTransferred", "SourceServerID", aws_drs_source_server.primary.id],
            ["AWS/DRS", "NetworkIn", "SourceServerID", aws_drs_source_server.primary.id],
            ["AWS/DRS", "NetworkOut", "SourceServerID", aws_drs_source_server.primary.id]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "DRS Replication Metrics"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/DRS", "ReplicationStatus", "SourceServerID", aws_drs_source_server.primary.id],
            ["AWS/DRS", "EBSWriteOps", "SourceServerID", aws_drs_source_server.primary.id],
            ["AWS/DRS", "EBSReadOps", "SourceServerID", aws_drs_source_server.primary.id]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "DRS Status and Operations"
        }
      }
    ]
  })
}

# SSM Parameter for DRS configuration
resource "aws_ssm_parameter" "drs_config" {
  name        = "/${var.environment}/drs/config"
  description = "DRS configuration details"
  type        = "SecureString"
  value = jsonencode({
    template_id         = aws_drs_replication_configuration_template.dr_template.id
    source_server_id    = aws_drs_source_server.primary.id
    recovery_instance_id = aws_drs_recovery_instance.dr_instance.id
  })

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-drs-config"
      Purpose = "configuration"
    }
  )
}

# Data sources
data "aws_region" "current" {}
