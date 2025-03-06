# global_accelerator/variables.tf

variable "endpoint_ids" {
  description = "List of endpoint IDs (ALB ARNs) for the Global Accelerator."
  type        = list(string)
}
