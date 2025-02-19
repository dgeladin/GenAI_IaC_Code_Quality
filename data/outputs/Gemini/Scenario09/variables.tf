# variables.tf
variable "datadog_api_key" {
  type = string
  description = "Datadog API Key"
  sensitive = true
}

variable "datadog_app_key" {
  type = string
  description = "Datadog Application Key"
  sensitive = true
}