# lambda_function.tf

data "archive_file" "dr_failover_function_zip" {
  type        = "zip"
  output_path = "dr_failover_function.zip"
  source {
    content = file("dr_failover_function.js") # Path to your Lambda function code
  }
}

resource "aws_lambda_function" "dr_failover_function" {
  function_name = "dr-failover-function"
  runtime       = "nodejs14.x" # Or the latest Node.js version you prefer
  handler       = "index.handler" # Your handler function
  zip_file      = data.archive_file.dr_failover_function_zip.output_path
  role          = aws_iam_role.dr_lambda_role.arn # IAM role for Lambda permissions
  timeout = 30 # Adjust as needed

  environment {
    variables = {
      DR_CONFIGURATION_ID = aws_drs_replication_configuration_template.drs_template.id # Pass the DRS template ID
    }
  }

  tags = {
    Name        = "dr-failover-function"
    Environment = "dr"
  }

  depends_on = [
    aws_iam_role_policy_attachment.dr_lambda_policy_attachment,
    aws_drs_replication_configuration_template.drs_template
  ]
}

output "dr_failover_function_arn" {
  value = aws_lambda_function.dr_failover_function.arn
  description = "ARN of the DR failover Lambda function"
}