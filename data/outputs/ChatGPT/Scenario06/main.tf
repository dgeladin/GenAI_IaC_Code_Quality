module "lambda" {
  source             = "./modules/lambda"
  lambda_name        = var.lambda_name
  lambda_runtime     = var.lambda_runtime
  lambda_handler     = var.lambda_handler
  lambda_filename    = var.lambda_filename
  memory_size        = var.memory_size
  timeout           = var.timeout
  environment_variables = var.environment_variables
}

module "api_gateway" {
  source                = "./modules/api_gateway"
  api_name              = var.api_name
  resource_path         = var.resource_path
  http_method           = var.http_method
  stage_name            = var.stage_name
  lambda_invoke_arn     = module.lambda.lambda_invoke_arn
  lambda_function_name  = module.lambda.lambda_function_arn
}

