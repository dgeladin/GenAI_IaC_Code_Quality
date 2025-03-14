resource "aws_cloudwatch_event_rule" "dr_failover" {
  provider    = aws.dr
  name        = "dr-failover-event-rule"
  description = "Triggers DR failover based on AWS Health events indicating an issue in the primary region"

  event_pattern = <<EOF
{
  "source": ["aws.health"],
  "detail-type": ["AWS Health Event"],
  "detail": {
    "service": ["EC2"],
    "eventTypeCategory": ["issue"],
    "region": ["us-west-2"]
  }
}
EOF
}

