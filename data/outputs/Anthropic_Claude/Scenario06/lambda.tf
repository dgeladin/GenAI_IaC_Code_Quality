resource "aws_lambda_function" "example_lambda_function" {
  function_name    = "example_lambda_function"
  role             = aws_iam_role.serverless_lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  tags = {
    Environment = var.environment
    Function    = "api_handler"
  }
}