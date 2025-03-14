variable "primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-west-2"
}

variable "dr_region" {
  description = "Disaster Recovery (DR) AWS region"
  type        = string
  default     = "us-east-1"
}

variable "primary_instance_ami" {
  description = "AMI ID for the primary EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "primary_instance_type" {
  description = "Instance type for the primary EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "primary_volume_size" {
  description = "Size of the primary EBS volume (in GB)"
  type        = number
  default     = 100
}

variable "primary_volume_type" {
  description = "Type of the primary EBS volume"
  type        = string
  default     = "gp3"
}

variable "s3_backup_bucket_name" {
  description = "Name of the S3 bucket for backups"
  type        = string
  default     = "example-dr-backup-bucket"
}

variable "kms_key_deletion_window" {
  description = "Number of days before KMS key deletion"
  type        = number
  default     = 10
}

variable "lambda_function_name" {
  description = "Name of the DR failover Lambda function"
  type        = string
  default     = "drFailoverFunction"
}

variable "lambda_runtime" {
  description = "Runtime environment for the Lambda function"
  type        = string
  default     = "nodejs14.x"
}

variable "lambda_handler" {
  description = "Handler function for the Lambda function"
  type        = string
  default     = "index.handler"
}

variable "dr_replication_template_id" {
  description = "ID of the AWS DRS replication configuration template"
  type        = string
}

