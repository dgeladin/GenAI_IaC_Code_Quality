# CloudWatch Event Rule for DR failover
resource "aws_cloudwatch_event_rule" "dr_failover" {
  name        = "${var.environment}-dr-failover-rule"
  description = "Triggers DR failover based on AWS Health events in primary region"

  event_pattern = jsonencode({
    source      = ["aws.health"]
    detail-type = ["AWS Health Event"]
    detail = {
      service = var.monitored_services
      eventTypeCategory = ["issue"]
      region = [var.primary_region]
      statusCode = ["open", "upcoming"]
      severity   = var.severity_levels
    }
  })

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-failover-rule"
      Purpose = "disaster-recovery"
    }
  )
}

# CloudWatch Event Rule for infrastructure health checks
resource "aws_cloudwatch_event_rule" "infrastructure_health" {
  name        = "${var.environment}-infrastructure-health-rule"
  description = "Monitors infrastructure health metrics"

  event_pattern = jsonencode({
    source      = ["aws.ec2", "aws.rds", "aws.elasticloadbalancing"]
    detail-type = [
      "EC2 Instance State-change Notification",
      "RDS DB Instance Event",
      "AWS API Call via CloudTrail"
    ]
    detail = {
      state = ["stopped", "terminated", "failed"]
    }
  })

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-infrastructure-health-rule"
      Purpose = "monitoring"
    }
  )
}

# CloudWatch Event Rule for scheduled health checks
resource "aws_cloudwatch_event_rule" "scheduled_health_check" {
  name                = "${var.environment}-scheduled-health-check"
  description         = "Scheduled health check for DR readiness"
  schedule_expression = var.health_check_schedule

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-scheduled-health-check"
      Purpose = "monitoring"
    }
  )
}

# Event target for Lambda function
resource "aws_cloudwatch_event_target" "dr_failover_lambda" {
  rule      = aws_cloudwatch_event_rule.dr_failover.name
  target_id = "DR-Failover-Lambda"
  arn       = var.lambda_function_arn
  role_arn  = aws_iam_role.eventbridge_role.arn

  # Retry policy for failed invocations
  retry_policy {
    maximum_event_age_in_seconds = 3600
    maximum_retry_attempts       = 2
  }

  # Input transformer
  input_transformer {
    input_paths = {
      eventTime = "$.time"
      region    = "$.detail.region"
      service   = "$.detail.service"
      issue     = "$.detail.eventTypeCode"
      severity  = "$.detail.severity"
      account   = "$.account"
    }
    input_template = <<EOF
{
  "failoverDetails": {
    "timestamp": <eventTime>,
    "affectedRegion": <region>,
    "affectedService": <service>,
    "issueType": <issue>,
    "severity": <severity>,
    "accountId": <account>,
    "environment": "${var.environment}"
  },
  "action": "INITIATE_FAILOVER"
}
EOF
  }
}

# Event target for SNS notifications
resource "aws_cloudwatch_event_target" "dr_failover_sns" {
  rule      = aws_cloudwatch_event_rule.dr_failover.name
  target_id = "DR-Failover-SNS"
  arn       = var.sns_topic_arn
  role_arn  = aws_iam_role.eventbridge_role.arn

  # Input transformer for SNS messages
  input_transformer {
    input_paths = {
      eventTime = "$.time"
      region    = "$.detail.region"
      service   = "$.detail.service"
      issue     = "$.detail.eventTypeCode"
      severity  = "$.detail.severity"
    }
    input_template = "DR Failover Alert: AWS Health event detected for ${var.environment} environment. Service: <service>, Region: <region>, Issue: <issue>, Severity: <severity>, Time: <eventTime>"
  }
}

# IAM role for EventBridge
resource "aws_iam_role" "eventbridge_role" {
  name = "${var.environment}-dr-eventbridge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM policy for EventBridge
resource "aws_iam_role_policy" "eventbridge_policy" {
  name = "${var.environment}-dr-eventbridge-policy"
  role = aws_iam_role.eventbridge_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [var.lambda_function_arn]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = [var.sns_topic_arn]
      }
    ]
  })
}

# CloudWatch Metric Alarm for rule triggers
resource "aws_cloudwatch_metric_alarm" "dr_failover_trigger" {
  alarm_name          = "${var.environment}-dr-failover-trigger-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "TriggeredRules"
  namespace           = "AWS/Events"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "DR failover rule has been triggered"
  alarm_actions      = [var.sns_topic_arn]

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.dr_failover.name
  }

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-failover-trigger-alarm"
      Purpose = "monitoring"
    }
  )
}

# CloudWatch Dashboard for DR events
resource "aws_cloudwatch_dashboard" "dr_events" {
  dashboard_name = "${var.environment}-dr-events-dashboard"

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
            ["AWS/Events", "TriggeredRules", "RuleName", aws_cloudwatch_event_rule.dr_failover.name],
            ["AWS/Events", "FailedInvocations", "RuleName", aws_cloudwatch_event_rule.dr_failover.name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "DR Event Metrics"
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
            aws_cloudwatch_metric_alarm.dr_failover_trigger.arn
          ]
          title = "DR Trigger Alarms"
        }
      }
    ]
  })
}

# Data sources
data "aws_region" "current" {}
