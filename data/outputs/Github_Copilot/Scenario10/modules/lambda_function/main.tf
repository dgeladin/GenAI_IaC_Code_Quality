resource "aws_lambda_function" "dr_failover" {
  filename         = "dr_failover_function.zip"
  function_name    = "dr_failover"
  role             = aws_iam_role.dr_lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  source_code_hash = filebase64sha256("dr_failover_function.zip")

  environment {
    variables = {
      DR_CONFIGURATION_ID = module.drs_replication_configuration.drs_replication_configuration_template_id
    }
  }

  tags = {
    Name        = "dr_failover_lambda_function"
    Environment = "DR"
  }
}

resource "aws_cloudwatch_event_target" "dr_failover" {
  rule      = module.cloudwatch_event_rule.event_rule_arn
  target_id = "dr_failover_lambda"
  arn       = aws_lambda_function.dr_failover.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dr_failover.function_name
  principal     = "events.amazonaws.com"
  source_arn    = module.cloudwatch_event_rule.event_rule_arn
}

output "lambda_function_arn" {
  value = aws_lambda_function.dr_failover.arn
}