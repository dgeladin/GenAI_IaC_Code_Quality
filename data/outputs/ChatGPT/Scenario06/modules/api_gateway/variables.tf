variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "example_api"
}

variable "resource_path" {
  description = "Path part of the API Gateway resource"
  type        = string
  default     = "example"
}

variable "http_method" {
  description = "HTTP method for the API Gateway method"
  type        = string
  default     = "GET"
}

variable "stage_name" {
  description = "Stage name for the API Gateway deployment"
  type        = string
  default     = "prod"
}

variable "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

