resource "aws_cloudwatch_event_rule" "dr_failover" {
  provider = aws.primary

  name        = "dr_failover"
  description = "Trigger DR failover based on AWS Health events in the primary region"

  event_pattern = jsonencode({
    "source": [
      "aws.health"
    ],
    "detail-type": [
      "AWS Health Event"
    ],
    "detail": {
      "service": [
        "EC2"
      ],
      "eventTypeCategory": [
        "issue"
      ],
      "region": [
        "us-west-2"
      ]
    }
  })

  tags = {
    Name        = "dr_failover_rule"
    Environment = "DR"
  }
}

output "event_rule_arn" {
  value = aws_cloudwatch_event_rule.dr_failover.arn
}