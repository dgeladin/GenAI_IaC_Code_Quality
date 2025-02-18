# SNS Topic for DR notifications
resource "aws_sns_topic" "dr_notifications" {
  provider = aws.dr_region
  name     = "${var.environment}-dr-notifications"
  
  tags = merge(var.project_tags, {
    Name        = "${var.environment}-dr-notifications"
    Purpose     = "disaster-recovery-notifications"
  })
}

# S3 Backup Configuration
module "dr_backup" {
  source = "../../modules/dr_backup"
  providers = {
    aws = aws.dr_region
  }

  environment  = var.environment
  bucket_name  = "${var.environment}-dr-backup-${data.aws_caller_identity.current.account_id}"
  dr_region    = var.dr_region
  primary_region = var.primary_region

  tags = var.project_tags
}

# Primary Instance Configuration
module "primary_instance" {
  source = "../../modules/primary_instance"
  providers = {
    aws = aws.primary_region
  }

  environment   = var.environment
  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  volume_size   = 100
  volume_type   = "gp3"

  tags = var.project_tags
}

# DRS Configuration
module "drs_config" {
  source = "../../modules/drs_config"
  providers = {
    aws = aws.dr_region
  }

  environment     = var.environment
  source_server_id = module.primary_instance.instance_id
  subnet_id       = var.dr_subnet_id
  security_group_ids = [var.dr_security_group_id]
  kms_key_arn     = module.dr_kms.key_arn

  tags = var.project_tags
}

# KMS Key Configuration
module "dr_kms" {
  source = "../../modules/dr_iam"
  providers = {
    aws = aws.dr_region
  }

  environment   = var.environment
  function_name = "dr-failover-handler"
  sns_topic_arn = aws_sns_topic.dr_notifications.arn
  
  drs_resources = {
    source_server_ids = [module.primary_instance.instance_id]
    template_id       = module.drs_config.replication_template_id
  }

  tags = var.project_tags
}

# Lambda Function Configuration
module "dr_lambda" {
  source = "../../modules/dr_lambda"
  providers = {
    aws = aws.dr_region
  }

  environment          = var.environment
  function_name        = "dr-failover-handler"
  drs_configuration_id = module.drs_config.replication_template_id
  sns_topic_arn       = aws_sns_topic.dr_notifications.arn

  tags = var.project_tags
}

# CloudWatch Events Configuration
module "dr_events" {
  source = "../../modules/dr_events"
  providers = {
    aws = aws.dr_region
  }

  environment     = var.environment
  primary_region  = var.primary_region
  monitored_services = ["EC2"]
  sns_topic_arn   = aws_sns_topic.dr_notifications.arn
  lambda_function_arn = module.dr_lambda.function_arn

  tags = var.project_tags
}

# Event Target Configuration
module "dr_event_target" {
  source = "../../modules/dr_event_target"
  providers = {
    aws = aws.dr_region
  }

  environment         = var.environment
  event_rule_name    = module.dr_events.rule_name
  lambda_function_arn = module.dr_lambda.function_arn

  tags = var.project_tags
}

# Data sources
data "aws_caller_identity" "current" {}
