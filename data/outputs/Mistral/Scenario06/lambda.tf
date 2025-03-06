# Define the Lambda function
resource "aws_lambda_function" "example_lambda_function" {
  function_name = "example_lambda_function"
  runtime       = "nodejs14.x"
  role          = aws_iam_role.serverless_lambda_role.arn
  handler       = "index.handler"

  # Reference the ZIP archive containing the Lambda function code
  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  # Environment variables can be defined here if needed
  # environment {
  #   variables = {
  #     key = "value"
  #   }
  # }
}
