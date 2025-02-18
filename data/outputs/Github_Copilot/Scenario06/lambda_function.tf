resource "aws_lambda_function" "example_lambda_function" {
  function_name = "example_lambda_function"
  runtime       = "nodejs14.x"
  role          = aws_iam_role.serverless_lambda_role.arn
  handler       = "index.handler"
  filename      = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  tags = {
    Name = "example_lambda_function"
  }
}