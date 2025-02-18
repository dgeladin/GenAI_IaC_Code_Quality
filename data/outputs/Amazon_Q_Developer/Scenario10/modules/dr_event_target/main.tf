# Event target for Lambda function
resource "aws_cloudwatch_event_target" "dr_failover" {
  rule      = var.event_rule_name
  target_id = "${var.environment}-dr-failover-target"
  arn       = var.lambda_function_arn
  role_arn  = aws_iam_role.event_target.arn

  # Retry policy for failed invocations
  retry_policy {
    maximum_event_age_in_seconds = 3600  # 1 hour
    maximum_retry_attempts       = 2
  }

  # Dead letter queue configuration
  dead_letter_config {
    arn = aws_sqs_queue.dr_dlq.arn
  }

  # Input transformer to customize the event data sent to Lambda
  input_transformer {
    input_paths = {
      eventTime = "$.time"
      region    = "$.detail.region"
      service   = "$.detail.service"
      issue     = "$.detail.eventTypeCode"
      account   = "$.account"
      resources = "$.resources"
      severity  = "$.detail.severity"
    }
    input_template = <<EOF
{
  "failoverDetails": {
    "timestamp": <eventTime>,
    "affectedRegion": <region>,
    "affectedService": <service>,
    "issueType": <issue>,
    "accountId": <account>,
    "severity": <severity>,
    "affectedResources": <resources>,
    "environment": "${var.environment}"
  },
  "action": "INITIATE_FAILOVER",
  "metadata": {
    "initiatedBy": "EventBridge",
    "automatedResponse": true,
    "environment": "${var.environment}"
  }
}
EOF
  }
}

# Dead letter queue for failed events
resource "aws_sqs_queue" "dr_dlq" {
  name = "${var.environment}-dr-failover-dlq"
  
  # DLQ configuration
  message_retention_seconds = 1209600  # 14 days
  visibility_timeout_seconds = 300     # 5 minutes
  delay_seconds = 0
  max_message_size = 262144           # 256 KB
  receive_wait_time_seconds = 20      # Enable long polling
  
  # Enable encryption
  sqs_managed_sse_enabled = true

  # Enable DLQ monitoring
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.dr_dlq.arn]
  })

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-failover-dlq"
      Purpose = "event-failure-handling"
    }
  )
}

# IAM role for EventBridge target
resource "aws_iam_role" "event_target" {
  name = "${var.environment}-dr-event-target-role"

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

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-event-target-role"
      Purpose = "eventbridge-target"
    }
  )
}

# IAM policy for EventBridge target
resource "aws_iam_role_policy" "event_target" {
  name = "${var.environment}-dr-event-target-policy"
  role = aws_iam_role.event_target.id

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
          "sqs:SendMessage"
        ]
        Resource = [aws_sqs_queue.dr_dlq.arn]
      }
    ]
  })
}

# CloudWatch alarms for DLQ monitoring
resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "${var.environment}-dr-failover-dlq-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "DR failover events in Dead Letter Queue"
  alarm_actions      = var.alarm_actions
  ok_actions         = var.alarm_actions

  dimensions = {
    QueueName = aws_sqs_queue.dr_dlq.name
  }

  tags = merge(
    var.tags,
    {
      Name    = "${var.environment}-dr-failover-dlq-alarm"
      Purpose = "monitoring"
    }
  )
}

# CloudWatch Dashboard for monitoring
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
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", aws_sqs_queue.dr_dlq.name],
            ["AWS/SQS", "ApproximateAgeOfOldestMessage", "QueueName", aws_sqs_queue.dr_dlq.name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "DLQ Metrics"
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
            ["AWS/Events", "FailedInvocations", "RuleName", var.event_rule_name],
            ["AWS/Events", "TriggeredRules", "RuleName", var.event_rule_name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "EventBridge Metrics"
        }
      }
    ]
  })
}

# Data sources
data "aws_region" "current" {}
