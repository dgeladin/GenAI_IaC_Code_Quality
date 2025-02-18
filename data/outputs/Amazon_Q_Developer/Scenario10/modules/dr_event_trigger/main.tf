# CloudWatch Event Rule for DR failover trigger
resource "aws_cloudwatch_event_rule" "dr_trigger" {
  name        = "${var.environment}-dr-failover-trigger"
  description = "Triggers DR failover based on defined health events"

  # Event pattern for AWS Health events
  event_pattern = jsonencode({
    source      = ["aws.health"]
    detail-type = ["AWS Health Event"]
    detail = {
      service = var.monitored_services
      eventTypeCategory = ["issue", "scheduledChange"]
      region = [var.primary_region]
      statusCode = ["open", "upcoming"]
      severity   = var.severity_levels
    }
  })

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-failover-trigger"
      Purpose = "disaster-recovery"
    }
  )
}

# CloudWatch Event Rule for custom application health checks
resource "aws_cloudwatch_event_rule" "app_health_trigger" {
  count       = var.enable_app_health_check ? 1 : 0
  name        = "${var.environment}-dr-app-health-trigger"
  description = "Triggers DR failover based on application health checks"
  
  schedule_expression = var.health_check_schedule

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-app-health-trigger"
      Purpose = "application-health-monitoring"
    }
  )
}

# CloudWatch Composite Alarm
resource "aws_cloudwatch_composite_alarm" "dr_trigger" {
  alarm_name        = "${var.environment}-dr-failover-composite-alarm"
  alarm_description = "Composite alarm for DR failover triggers"

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions

  alarm_rule = <<-EOF
    ALARM(${aws_cloudwatch_metric_alarm.service_health.alarm_name}) OR
    ALARM(${aws_cloudwatch_metric_alarm.instance_health.alarm_name})
    ${var.enable_app_health_check ? "OR ALARM(${aws_cloudwatch_metric_alarm.app_health[0].alarm_name})" : ""}
  EOF

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-composite-alarm"
      Purpose = "disaster-recovery"
    }
  )
}

# Service Health Metric Alarm
resource "aws_cloudwatch_metric_alarm" "service_health" {
  alarm_name          = "${var.environment}-dr-service-health"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthEventCount"
  namespace           = "AWS/Health"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "Monitors AWS Health events for critical services"

  dimensions = {
    Region = var.primary_region
  }

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-service-health-alarm"
      Purpose = "monitoring"
    }
  )
}

# Instance Health Metric Alarm
resource "aws_cloudwatch_metric_alarm" "instance_health" {
  alarm_name          = "${var.environment}-dr-instance-health"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period             = "300"
  statistic          = "Maximum"
  threshold          = "0"
  alarm_description  = "Monitors EC2 instance health status"

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-instance-health-alarm"
      Purpose = "monitoring"
    }
  )
}

# Application Health Metric Alarm
resource "aws_cloudwatch_metric_alarm" "app_health" {
  count               = var.enable_app_health_check ? 1 : 0
  alarm_name          = "${var.environment}-dr-app-health"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthCheckStatus"
  namespace           = "Custom/Application"
  period             = "300"
  statistic          = "Maximum"
  threshold          = "0"
  alarm_description  = "Monitors application health status"

  dimensions = {
    Application = var.application_name
    Environment = var.environment
  }

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-app-health-alarm"
      Purpose = "monitoring"
    }
  )
}

# SNS Topic for health notifications
resource "aws_sns_topic" "health_notifications" {
  name = "${var.environment}-dr-health-notifications"
  
  kms_master_key_id = "alias/aws/sns"

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-health-notifications"
      Purpose = "monitoring"
    }
  )
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "dr_health" {
  dashboard_name = "${var.environment}-dr-health-dashboard"

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
            ["AWS/Health", "HealthEventCount", "Region", var.primary_region],
            ["AWS/EC2", "StatusCheckFailed", "InstanceId", var.instance_id]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.primary_region
          title   = "Health Metrics"
        }
      },
      {
        type   = "alarm"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          alarms = [
            aws_cloudwatch_composite_alarm.dr_trigger.arn
          ]
          title = "DR Trigger Alarms"
        }
      }
    ]
  })
}

# EventBridge API Destination (optional)
resource "aws_cloudwatch_event_api_destination" "notification_webhook" {
  count           = var.enable_webhook_notification ? 1 : 0
  name           = "${var.environment}-dr-webhook"
  description    = "Webhook for DR health notifications"
  invocation_endpoint = var.webhook_url
  http_method    = "POST"
  
  connection_arn = aws_cloudwatch_event_connection.webhook[0].arn
}

# EventBridge Connection for API Destination
resource "aws_cloudwatch_event_connection" "webhook" {
  count           = var.enable_webhook_notification ? 1 : 0
  name           = "${var.environment}-dr-webhook-connection"
  description    = "Connection for DR health notifications webhook"
  
  authorization_type = "API_KEY"
  
  auth_parameters {
    api_key {
      key   = "Authorization"
      value = var.webhook_auth_key
    }
  }
}
