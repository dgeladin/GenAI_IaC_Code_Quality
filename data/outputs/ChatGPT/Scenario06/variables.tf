variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "lambda_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "example_lambda_function"
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "nodejs14.x"
}

variable "lambda_handler" {
  description = "Handler function for the Lambda"
  type        = string
  default     = "index.handler"
}

variable "lambda_filename" {
  description = "Path to the Lambda deployment package"
  type        = string
  default     = "lambda_function.zip"
}

variable "memory_size" {
  description = "Memory allocated to the Lambda function"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout for the Lambda function"
  type        = number
  default     = 3
}

variable "environment_variables" {
  description = "Environment variables for Lambda function"
  type        = map(string)
  default     = {}
}

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
  description = "Stage name for API Gateway deployment"
  type        = string
  default     = "prod"
}

