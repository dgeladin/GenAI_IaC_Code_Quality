# RDS Instance
resource "aws_db_instance" "example" {
  identifier = local.db_identifier

  # Engine specifications
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = var.db_instance_class != null ? var.db_instance_class : local.db_settings.instance_class
  
  # Storage configuration
  allocated_storage     = var.allocated_storage != null ? var.allocated_storage : local.db_settings.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id           = var.use_custom_kms_key ? var.kms_key_id : try(aws_kms_key.rds[0].arn, null)

  # Database details
  db_name  = "myapp"
  username = var.db_username
  password = var.db_password
  port     = local.db_port

  # Network & Security
  db_subnet_group_name   = aws_db_subnet_group.example.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az              = local.db_settings.multi_az
  publicly_accessible   = false

  # Backup configuration
  backup_retention_period = var.backup_retention_period != null ? var.backup_retention_period : local.db_settings.backup_retention
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  skip_final_snapshot    = local.db_settings.skip_final_snapshot
  final_snapshot_identifier = local.db_settings.skip_final_snapshot ? null : "${local.db_identifier}-final-${formatdate("YYYYMMDD-HHmmss", timestamp())}"
  copy_tags_to_snapshot  = true
  deletion_protection    = local.db_settings.deletion_protection

  # Enhanced monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn

  # Performance Insights
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  performance_insights_kms_key_id      = var.use_custom_kms_key ? var.kms_key_id : try(aws_kms_key.rds[0].arn, null)

  # Parameter and Option Groups
  parameter_group_name = aws_db_parameter_group.example.name
  option_group_name    = aws_db_option_group.example.name

  # Logging
  enabled_cloudwatch_logs_exports = local.log_types

  # Auto Minor Version Upgrade
  auto_minor_version_upgrade = true

  # Tags
  tags = merge(
    local.common_tags,
    var.additional_tags,
    {
      Name = local.db_identifier
    }
  )

  # Lifecycle
  lifecycle {
    prevent_destroy = local.is_production

    ignore_changes = [
      password,
      snapshot_identifier
    ]
  }

  depends_on = [
    aws_db_subnet_group.example,
    aws_security_group.db_sg,
    aws_iam_role.rds_monitoring_role
  ]
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  alarm_name          = "${local.db_identifier}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors RDS CPU utilization"
  alarm_actions      = []  # Add SNS topic ARN for notifications

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.example.id
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "database_memory" {
  alarm_name          = "${local.db_identifier}-freeable-memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "200000000"  # 200MB in bytes
  alarm_description   = "This metric monitors RDS freeable memory"
  alarm_actions      = []  # Add SNS topic ARN for notifications

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.example.id
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "database_disk_queue" {
  alarm_name          = "${local.db_identifier}-disk-queue-depth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "10"
  alarm_description   = "This metric monitors RDS disk queue depth"
  alarm_actions      = []  # Add SNS topic ARN for notifications

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.example.id
  }

  tags = local.common_tags
}

# Route53 DNS Record (Optional - uncomment if needed)
/*
resource "aws_route53_record" "database" {
  zone_id = var.route53_zone_id
  name    = "db.${var.environment}.example.com"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.example.endpoint]
}
*/

# SSM Parameters for database connection information
resource "aws_ssm_parameter" "database_host" {
  name        = "${local.ssm_path_prefix}/host"
  description = "Database host endpoint"
  type        = "String"
  value       = aws_db_instance.example.endpoint
  overwrite   = true

  tags = local.common_tags
}

resource "aws_ssm_parameter" "database_name" {
  name        = "${local.ssm_path_prefix}/name"
  description = "Database name"
  type        = "String"
  value       = aws_db_instance.example.db_name
  overwrite   = true

  tags = local.common_tags
}

resource "aws_ssm_parameter" "database_user" {
  name        = "${local.ssm_path_prefix}/user"
  description = "Database master username"
  type        = "SecureString"
  value       = var.db_username
  overwrite   = true

  tags = local.common_tags
}

resource "aws_ssm_parameter" "database_password" {
  name        = "${local.ssm_path_prefix}/password"
  description = "Database master password"
  type        = "SecureString"
  value       = var.db_password
  overwrite   = true

  tags = local.common_tags
}

# EventBridge rule for RDS events
resource "aws_cloudwatch_event_rule" "rds_events" {
  name        = "${local.db_identifier}-events"
  description = "Capture all RDS events"

  event_pattern = jsonencode({
    source      = ["aws.rds"]
    detail-type = ["RDS DB Instance Event"]
    detail = {
      SourceIdentifier = [aws_db_instance.example.id]
    }
  })

  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.rds_events.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.rds_events.arn
}

# SNS Topic for RDS events
resource "aws_sns_topic" "rds_events" {
  name = "${local.db_identifier}-events"

  tags = local.common_tags
}

resource "aws_sns_topic_policy" "rds_events" {
  arn = aws_sns_topic.rds_events.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEventBridgePublish"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.rds_events.arn
      }
    ]
  })
}

# Backup Selection for AWS Backup (Optional - uncomment if needed)
/*
resource "aws_backup_selection" "rds_backup" {
  name         = "${local.db_identifier}-backup"
  plan_id      = var.backup_plan_id
  iam_role_arn = var.backup_role_arn

  resources = [
    aws_db_instance.example.arn
  ]

  condition {
    string_equals = {
      "aws:ResourceTag/Environment" = var.environment
    }
  }
}
*/
