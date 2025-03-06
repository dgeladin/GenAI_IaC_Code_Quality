provider "aws" {
  alias  = "primary"
  region = var.region_primary
}

resource "aws_cloudwatch_event_rule" "dr_failover" {
  provider    = aws.primary
  name        = "dr-failover-rule"
  description = "Trigger DR failover based on AWS Health events for EC2 in the primary region"

  event_pattern = jsonencode({
    source      = ["aws.health"]
    detail-type = ["AWS Health Event"]
    detail = {
      service    = ["EC2"]
      region     = [var.region_primary]
      eventTypeCategory = ["issue"]
    }
  })
}

resource "aws_cloudwatch_event_target" "dr_failover_target" {
  provider  = aws.primary
  rule      = aws_cloudwatch_event_rule.dr_failover.name
  target_id = "dr_failover_handler"
  arn       = aws_lambda_function.dr_failover_handler.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke" {
  provider      = aws.primary
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dr_failover_handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.dr_failover.arn
}
