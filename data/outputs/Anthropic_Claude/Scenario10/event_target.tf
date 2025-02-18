# filename: event_target.tf

# CloudWatch Event Target for Lambda
resource "aws_cloudwatch_event_target" "dr_lambda_target" {
  rule      = aws_cloudwatch_event_rule.dr_failover.name
  target_id = "DRFailoverLambda"
  arn       = aws_lambda_function.dr_failover.arn

  # Input transformation to standardize event data
  input_transformer {
    input_paths = {
      region   = "$.detail.region"
      service  = "$.detail.service"
      eventArn = "$.detail.eventArn"
      time     = "$.time"
    }
    
    input_template = jsonencode({
      timestamp    = "<time>"
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

# Lambda permission to allow CloudWatch Events
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowCloudWatchEventInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dr_failover.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.dr_failover.arn
}