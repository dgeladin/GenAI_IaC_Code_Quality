resource "aws_iam_role" "serverless_lambda_role" {
  name = "serverless_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.serverless_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "example_lambda_function" {
  function_name    = var.lambda_name
  role            = aws_iam_role.serverless_lambda_role.arn
  handler         = var.lambda_handler
  runtime         = var.lambda_runtime
  filename        = var.lambda_filename
  source_code_hash = filebase64sha256(var.lambda_filename)
  
  memory_size     = var.memory_size
  timeout         = var.timeout

  environment {
    variables = var.environment_variables
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_basic_execution]
}

