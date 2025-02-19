# variables.tf
variable "region" {
  type    = string
  default = "us-west-2"
  description = "AWS region"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
  description = "List of availability zones"
}

variable "cluster_name" {
  type    = string
  default = "my-eks-cluster"
  description = "Name of the EKS cluster"
}

variable "kubernetes_version" {
  type    = string
  default = "1.31"
  description = "Kubernetes version"
}

variable "node_group_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
  description = "Instance types for the worker nodes"
}

variable "node_group_desired_capacity" {
  type    = number
  default = 3
  description = "Desired number of worker nodes"
}

variable "node_group_min_size" {
  type    = number
  default = 2
  description = "Minimum number of worker nodes"
}

variable "node_group_max_size" {
  type    = number
  default = 5
  description = "Maximum number of worker nodes"
}

variable "api_domain" {
  type = string
  description = "Domain name for the API"
}

variable "api_service_name" {
  type = string
  description = "Name of the Kubernetes API service"
}

variable "acm_certificate_domain" {
  type = string
  description = "Domain name of the ACM certificate"
}
