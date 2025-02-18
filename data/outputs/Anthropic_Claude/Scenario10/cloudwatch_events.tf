# filename: cloudwatch_events.tf

# IAM role for CloudWatch Events
resource "aws_iam_role" "dr_failover_role" {
  name = "dr-failover-role"

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

  tags = var.common_tags
}

# IAM policy for the CloudWatch Events role
resource "aws_iam_role_policy" "dr_failover_policy" {
  name = "dr-failover-policy"
  role = aws_iam_role.dr_failover_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "drs:StartRecoveryJob",
          "drs:DescribeSourceServers",
          "drs:GetReplicationConfiguration"
        ]
        Resource = "*"
      }
    ]
  })
}

# CloudWatch Event Rule for DR failover
resource "aws_cloudwatch_event_rule" "dr_failover" {
  name        = "dr-failover-trigger"
  description = "Triggers DR failover based on AWS Health events for EC2 in primary region"

  event_pattern = jsonencode({
    source      = ["aws.health"]
    detail-type = ["AWS Health Event"]
    detail = {
      service = ["EC2"]
      eventTypeCategory = ["issue"]
      region = ["us-west-2"]
    }
  })

  tags = merge(
    var.common_tags,
    {
      Name = "DR-Failover-Rule"
      Purpose = "Automated DR Failover"
    }
  )
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "dr_failover_target" {
  rule      = aws_cloudwatch_event_rule.dr_failover.name
  target_id = "DRFailoverTarget"
  arn       = var.recovery_automation_lambda_arn
  role_arn  = aws_iam_role.dr_failover_role.arn

  input_transformer {
    input_paths = {
      region   = "$.detail.region"
      service  = "$.detail.service"
      eventArn = "$.detail.eventArn"
    }
    input_template = jsonencode({
      sourceRegion = "us-west-2"
      targetRegion = "us-east-1"
      eventDetails = {
        region   = "<region>"
        service  = "<service>"
        eventArn = "<eventArn>"
      }
    })
  }
}

# CloudWatch Event Rule metrics
resource "aws_cloudwatch_metric_alarm" "dr_failover_trigger" {
  alarm_name          = "dr-failover-triggered"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "TriggeredRules"
  namespace           = "AWS/Events"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "This metric monitors DR failover rule triggers"
  
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.dr_failover.name
  }

  alarm_actions = [var.notification_topic_arn]
  
  tags = var.common_tags
}