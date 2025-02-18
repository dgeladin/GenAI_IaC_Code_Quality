resource "aws_lambda_function" "example_lambda_function" {
  function_name    = "example_lambda_function"
  runtime          = "nodejs14.x"
  role             = var.lambda_role_arn
  handler          = "index.handler"
  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  tags = {
    Name = "example_lambda_function"
  }
}

output "lambda_function_invoke_arn" {
  value = aws_lambda_function.example_lambda_function.invoke_arn
}

output "lambda_function_arn" {
  value = aws_lambda_function.example_lambda_function.arn
}

variable "lambda_role_arn" {
  description = "The ARN of the IAM role that the Lambda function will use"
  type        = string
}