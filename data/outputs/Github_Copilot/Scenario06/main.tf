provider "aws" {
  region = "us-east-1"
}

module "iam" {
  source = "./iam"
}

module "lambda" {
  source = "./lambda"
  lambda_role_arn = module.iam.serverless_lambda_role_arn
}

module "api_gateway" {
  source = "./api_gateway"
  lambda_function_invoke_arn = module.lambda.lambda_function_invoke_arn
  lambda_function_arn = module.lambda.lambda_function_arn
}

output "api_url" {
  value = "${module.api_gateway.api_invoke_url}/example"
}