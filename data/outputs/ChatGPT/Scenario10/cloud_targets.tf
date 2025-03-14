resource "aws_cloudwatch_event_target" "dr_failover_target" {
  provider  = aws.dr
  rule      = aws_cloudwatch_event_rule.dr_failover.name
  target_id = "invoke-dr-failover"
  arn       = "arn:aws:lambda:us-east-1:123456789012:function:drFailoverFunction"  # Replace with actual Lambda function ARN
}

