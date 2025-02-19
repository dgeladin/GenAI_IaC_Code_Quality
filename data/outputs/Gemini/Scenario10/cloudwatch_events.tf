# cloudwatch_events.tf

resource "aws_cloudwatch_event_rule" "dr_failover" {
  name        = "dr-failover-rule"
  description = "CloudWatch rule to trigger DR failover on AWS Health events"

  event_pattern = jsonencode({
    "source": ["aws.health"],
    "detail-type": ["AWS Health Event"],
    "region": ["us-west-2"], # Filter for primary region
    "detail": {
      "service": ["EC2"], # Filter for EC2 service
      "eventTypeCategory": ["issue"] # Filter for issues
    }
  })

  tags = {
    Name        = "dr-failover-rule"
    Environment = "dr"
  }
}

resource "aws_cloudwatch_event_target" "dr_failover_target" {
  rule      = aws_cloudwatch_event_rule.dr_failover.name
  arn       = aws_lambda_function.dr_failover_function.arn # Connect to the Lambda function
}

# Output the CloudWatch Event Rule ARN
output "dr_failover_rule_arn" {
  value = aws_cloudwatch_event_rule.dr_failover.arn
  description = "ARN of the DR failover CloudWatch Event Rule"
}