variable "lambda_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "example_lambda_function"
}

variable "lambda_runtime" {
  description = "Runtime environment for the Lambda function"
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
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 3
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

