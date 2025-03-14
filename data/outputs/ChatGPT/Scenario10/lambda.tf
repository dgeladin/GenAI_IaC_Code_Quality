resource "aws_lambda_function" "dr_failover" {
  provider         = aws.dr
  function_name    = var.lambda_function_name
  role            = aws_iam_role.dr_lambda_role.arn
  handler         = var.lambda_handler
  runtime         = var.lambda_runtime
  filename        = "dr_failover_function.zip"
  source_code_hash = filebase64sha256("dr_failover_function.zip")

  environment {
    variables = {
      DR_CONFIGURATION_ID = var.dr_replication_template_id
    }
  }

  tags = {
    Name        = "dr-failover-lambda"
    Environment = "disaster-recovery"
  }
}

